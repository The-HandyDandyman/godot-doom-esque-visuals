shader_type spatial;
render_mode unshaded, depth_prepass_alpha, depth_draw_opaque;

// rows - directions, column - animation frames
// First (0) row - front
// Last row - back
// Rows inbetween - consecutive rotations

uniform vec4 modulate : source_color = vec4(255,255,255,255);
uniform sampler2D sprite_sheet: filter_nearest;

// Total rows and columns
uniform int directions = 8;
uniform int frames = 4;

uniform int animframe = 0;

uniform bool asymmetrical = false;

uniform bool y_billboard = false;

varying vec3 look_dir;

void vertex() {
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

	ALBEDO = tex.rgb * modulate.rgb;
	ALPHA =  tex.a * modulate.a;
}