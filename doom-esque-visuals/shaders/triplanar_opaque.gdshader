shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque; // Since this is set to cull_disabled, it will render both sides in most situations

uniform float alpha_scissor_threshold : hint_range(0.0, 1.0, 0.001);

const vec3 dither = vec3(0.06711056f, 0.00583715f, 52.9829189f);

uniform sampler2D texture_albedo:source_color,filter_nearest; 
uniform vec4 modulate : source_color = vec4(255,255,255,255);

uniform float tile_scale = 1.0;
varying vec2 texture_ratio;
uniform float blend_sharpness = 4.0;
uniform vec2 texture_offset;
uniform int rotation_degrees:hint_range(-360,360);

uniform bool render_front = true;
uniform bool render_back = true;
// if the texture is displaying flipped, use this to fix it up!
uniform bool fix_back = false;
uniform bool flip_texture = false;


uniform sampler2D mask_texture:source_color,filter_nearest; 
uniform float mask_scale = 1.0;
varying vec2 mask_ratio;
uniform vec2 mask_offset;
uniform int mask_rotation:hint_range(-360,360);

uniform bool mask_back_flip = false;
uniform float mask_intensity:hint_range(0.0,1.0) = 0.0;

varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize(mat3(MODEL_MATRIX) * NORMAL);
}

void fragment() {
	// Get texture size and ratio
	vec2 texture_size = vec2(textureSize(texture_albedo,0));
	texture_ratio = vec2(1.0,texture_size.x/texture_size.y);
	// Get mask size and ratio
	vec2 mask_size = vec2(textureSize(mask_texture,0));
	mask_ratio = vec2(1.0,mask_size.x/mask_size.y);
	if (!render_front && FRONT_FACING){ //Discard if render front or render back are disabled
		discard;
	}
	if (!render_back && !FRONT_FACING){
		discard;
	}
    vec3 n = normalize(world_normal);
    vec3 abs_normal = abs(n);
    
    float top_weight = pow(abs_normal.y, blend_sharpness);
    float side_x_weight = pow(abs_normal.x, blend_sharpness);
    float side_z_weight = pow(abs_normal.z, blend_sharpness);
    float total_weight = top_weight + side_x_weight + side_z_weight;
    
    top_weight /= total_weight;
    side_x_weight /= total_weight;
    side_z_weight /= total_weight;
    
    vec2 uv_top = world_position.xz / -tile_scale * texture_ratio;
    vec2 uv_side_x = world_position.zy / -tile_scale * texture_ratio;
    vec2 uv_side_z = world_position.xy / -tile_scale * texture_ratio;
   
    vec2 uv = (top_weight > side_x_weight && top_weight > side_z_weight) ? uv_top :
               (side_x_weight > side_z_weight) ? uv_side_x : uv_side_z;
	uv += vec2(texture_offset) / texture_size;
	// Convert degree integer to a float in radians
	float rad = radians(float(rotation_degrees));
	// Calculate sine and cosine of the angle
	float sin_angle = sin(rad);
	float cos_angle = cos(rad);
	// apply sine and cosine
	uv = vec2(uv.x * cos_angle - uv.y * sin_angle,uv.x * sin_angle + uv.y * cos_angle);
	if (!FRONT_FACING && fix_back){ // flip horizontally if true
		uv.x = -uv.x;
	}
	if (flip_texture){
		uv.x = -uv.x;
	}
	
	// repeat process for mask
	uv_top = world_position.xz / -mask_scale * mask_ratio;
	uv_side_x = world_position.zy / -mask_scale * mask_ratio;
	uv_side_z = world_position.xy / -mask_scale * mask_ratio;
	vec2 mask_uv = (top_weight > side_x_weight && top_weight > side_z_weight) ? uv_top :
               (side_x_weight > side_z_weight) ? uv_side_x : uv_side_z;
	mask_uv += vec2(mask_offset) / mask_size;
	rad = radians(float(mask_rotation));
	sin_angle = sin(rad);
	cos_angle = cos(rad);
	mask_uv = vec2(mask_uv.x * cos_angle - mask_uv.y * sin_angle,mask_uv.x * sin_angle + mask_uv.y * cos_angle);
	if (!FRONT_FACING && fix_back){ // flip horizontally if true
		mask_uv.x = -mask_uv.x;
	}
	if (flip_texture){
		mask_uv.x = -mask_uv.x;
	}
	if (mask_back_flip && !FRONT_FACING){
		mask_uv.x = -mask_uv.x;
	}
	// Set up final albedo, then multiply alpha by texture mask
	vec4 final_albedo = texture(texture_albedo, uv);
	final_albedo.a *= texture(mask_texture,mask_uv).r + mask_intensity;
	final_albedo *= modulate;
	
	if (final_albedo.a < 0.001 || final_albedo.a < fract(dither.z * fract(dot(FRAGCOORD.xy, dither.xy)))) { // dither transparency
		discard;
	}
	ALBEDO = final_albedo.rgb;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
}