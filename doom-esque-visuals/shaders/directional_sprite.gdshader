shader_type spatial;
render_mode unshaded;

// rows - directions, column - animation frames
// First (0) row - front
// Last row - back
// Rows inbetween - consecutive rotations

uniform vec4 modulate : source_color = vec4(1.0,1.0,1.0,1.0);
uniform sampler2D sprite_sheet: source_color,filter_nearest,hint_default_transparent;

// Total rows and columns
uniform int directions = 8;
uniform int frames = 4;

uniform int animframe = 0;

uniform bool asymmetrical = false;

uniform bool y_billboard = false;

group_uniforms Dither;

uniform sampler2D dither_tex : repeat_enable,filter_nearest;
uniform float dither_scale = 1.0;

group_uniforms Lightmap;
uniform sampler2D lightmap:hint_default_white,filter_nearest;
uniform vec2 lightmap_size = vec2(1.0);
uniform vec2 lightmap_origin = vec2(0.0);
uniform bool use_lightmap = true;

group_uniforms LightMask;
uniform sampler2D light_mask:hint_default_black,filter_nearest;
uniform float light_mask_strength:hint_range(0.0,1.0) = 1.0;

group_uniforms Light_Diminishing;
global uniform bool light_diminishing = false;
global uniform float light_min_diminish = 0.0;
global uniform float light_max_diminish = 4.0;
global uniform float light_diminish_curve = 1.0;
global uniform bool radial_diminish = false;
global uniform bool color_banding = false;
global uniform int color_bands = 32;
global uniform bool fog_diminishing = false;
global uniform vec4 fog_modulate : source_color = vec4(0.0,0.0,0.0,1.0);
global uniform float fog_min_diminish = 0.0;
global uniform float fog_max_diminish = 4.0;
global uniform float fog_diminish_curve = 1.0;

varying vec3 look_dir;
varying flat vec3 world_origin;
varying vec2 adjusted_light_origin;
varying flat vec3 light_color;

vec3 screen(vec3 base, vec3 blend){
	return 1.0 - (1.0 - base) * (1.0 - blend);
}

float diminish_factor_calc(float min_val,float max_val, float dim_curve, float vertex_dim){
	float dim = pow(1.0 - smoothstep(min_val,max_val,vertex_dim),max(0.0,dim_curve)); // Initial calculations
	return  mix(dim,(floor(dim * float(color_bands)) / float(color_bands)),float(color_banding)); // Apply color banding if needed
}

vec3 create_lightmap_color(){
	return texture(lightmap,adjusted_light_origin).rgb;
}
void vertex() {
	world_origin = MODEL_MATRIX[3].xyz;
	mat4 modified_model_view;
	if (y_billboard){ // Y-Billboard
		modified_model_view = VIEW_MATRIX * mat4(
			vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0),
			vec4(0.0, 1.0, 0.0, 0.0),
			vec4(normalize(cross(MAIN_CAM_INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0),
			MODEL_MATRIX[3]
		);
	}else{ // Full billboard
		modified_model_view = VIEW_MATRIX * mat4(
			INV_VIEW_MATRIX[0],
			INV_VIEW_MATRIX[1],
			INV_VIEW_MATRIX[2],
			MODEL_MATRIX[3]
		);
	}
    MODELVIEW_MATRIX = modified_model_view * mat4(
	vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
	vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
	vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
	vec4(0.0, 0.0, 0.0, 1.0));
	// We use pre-billboard quad's NORMAL as the sprite's look_direction
	look_dir = MODELVIEW_NORMAL_MATRIX * NORMAL;
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	// Apply object scale last after other calculations have been run
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
	vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
	vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
	vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
	vec4(0.0, 0.0, 0.0, 1.0));
	// Handle lightmap colors: we're handling it in here so that way the light is just one color
	vec2 local_world_pos = world_origin.xz - lightmap_origin;
	adjusted_light_origin = (local_world_pos / lightmap_size) + vec2(0.5);
	light_color = create_lightmap_color();
}


void fragment() {
	float f_directions = float(directions);
	float f_ncolumns = float(frames);
	float f_nrows = float((f_directions / 2.0) + 1.0);
	float inbetweens = f_nrows - 2.0;
	// Simple frame looping
	// Animation frames should be controlled by script/uniform, though a loop is here for those who'd like it
	// float current_frame = trunc(mod(TIME * 5.0, f_ncolumns));

	// cam_dir = CAMERA_DIRECTION_WORLD; is sufficient for orthogonal camera
	vec3 ray_origin = CAMERA_POSITION_WORLD;
    // Instead of calculating object origin, uniform for mesh.global_position wold work better for x/y impostor billboard
	vec3 object_origin = (MODEL_MATRIX * vec4(0.0,0.0,0.0,1.0)).xyz;
	vec3 cam_dir = object_origin - ray_origin;
	cam_dir = normalize((VIEW_MATRIX * vec4(cam_dir, 0.0)).xyz);

	// Getting direction through dot product
	// Assumin that NPC looking at it's positive Z direction
	float angle = 180.0 - degrees(acos(dot(normalize(cam_dir.xz), normalize(look_dir.xz))));
	float _direction = round(angle/180.0 * (f_directions / 2.0));

	// Flipping left/right animations based on cross product
	float flip = sign((look_dir.x * cam_dir.z) - (look_dir.z * cam_dir.x));
	// Here we ignore flipping for "back" and "front" frames
	flip = mix(flip, 1.0, max(step(_direction, 0.0), step(f_nrows - 1.0, _direction)));
	

	float current_frame = float(animframe);
	// makes sure flip is oriented correctly and plays frames in the correct order if it flips, will ignore if it's asymmetrical though
	if (flip < float(0) && !asymmetrical) {
		current_frame = (current_frame * float(-1)) + f_nrows - (f_ncolumns - 4.0);
	}
	if (asymmetrical) { // Check if the sprite is supposed to be flipped, then set flip to 1 and makes sure the in betweens are done correctly
		if (_direction > float(0) && _direction < f_nrows && flip < float(0)){
			_direction = f_nrows - _direction + inbetweens;
		}
		flip = float(1);
	}else{ // make sure f_directions is set to f_nrows so that way the frame size calculations are set correctly
		f_directions = f_nrows;
	}
	// Getting correct frame
	vec2 frame = vec2(current_frame, _direction);
	vec2 frame_size = vec2(f_ncolumns, f_directions);
	vec4 tex = texture(sprite_sheet, (UV + frame) / frame_size * vec2(flip, 1.0));
	vec4 final_albedo = tex * modulate;
	// Handle dithered transparency
	ivec2 dither_size = textureSize(dither_tex, 0);
	vec2 f_dither_size = vec2(1.0 / float(dither_size.x), 1.0 / float(dither_size.y)) * vec2(1.0 / dither_scale);
	vec2 dither_uv = FRAGCOORD.xy * f_dither_size;
	float dither_threshold = texture(dither_tex, dither_uv).r;
	if (final_albedo.a < 0.001 || final_albedo.a < dither_threshold) {
		discard;
	}
	// Apply light mask to light color
	vec3 light_mask_tex = texture(light_mask,UV).rgb;
	vec3 light_color_masked = screen(light_color,light_mask_tex * vec3(light_mask_strength));
	light_color_masked = mix(light_color_masked,vec3(1.0),1.0 - float(use_lightmap));
	// Calculate light diminishing and fog
	float vertex_diminish = mix(-VERTEX.z,length(VERTEX),float(radial_diminish));
	float light_diminish_factor = diminish_factor_calc(light_min_diminish,light_max_diminish,light_diminish_curve,vertex_diminish);
	float fog_diminish_factor = diminish_factor_calc(fog_min_diminish,fog_max_diminish,fog_diminish_curve,vertex_diminish);
	// Create final light diminishing
	vec3 final_light_diminish = vec3(mix(0.0,light_diminish_factor,float(light_diminishing)));
	light_color_masked = screen(light_color_masked,final_light_diminish);
	vec3 complete_albedo = final_albedo.rgb * modulate.rgb * light_color_masked;
	vec3 fog_albedo = mix(complete_albedo,fog_modulate.rgb,1.0 - fog_diminish_factor);
	ALBEDO = mix(complete_albedo,fog_albedo,float(fog_diminishing));
	//ALBEDO = final_light_diminish;
}