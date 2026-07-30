shader_type spatial;
render_mode unshaded, cull_disabled; // Since this is set to cull_disabled, it will render both sides in most situations

uniform float blend_sharpness = 4.0;
uniform bool render_front = true;
uniform bool render_back = true;

group_uniforms Dither;
uniform sampler2D dither_tex : repeat_enable,filter_nearest,source_color,hint_default_white;
uniform float dither_scale = 1.0;


group_uniforms Texture;

uniform sampler2D texture_albedo:source_color,filter_nearest; 
uniform vec4 modulate : source_color = vec4(1.0,1.0,1.0,1.0);
uniform float tile_scale = 1.0;
uniform vec2 texture_offset;
uniform int rotation_degrees:hint_range(-360,360);

// if the texture is displaying flipped, use this to fix it up!
uniform bool fix_back = false; // Fix_back is mainly recommended for walls, it isn't really needed for floors and ceilings
uniform bool flip_texture = false;
uniform bool tex_world_pos = true;

group_uniforms Mask;
uniform sampler2D mask_texture:source_color,filter_nearest; 
uniform float mask_scale = 1.0;
uniform vec2 mask_offset;
uniform int mask_rotation:hint_range(-360,360);

uniform bool mask_back_flip = false;
uniform float mask_intensity:hint_range(0.0,1.0) = 0.0;
uniform bool mask_world_pos = true;

group_uniforms Overlay;
uniform sampler2D overlay_texture:source_color,filter_nearest,hint_default_transparent; 
uniform vec4 overlay_modulate : source_color = vec4(1.0,1.0,1.0,1.0);
uniform float overlay_scale = 1.0;
uniform vec2 overlay_offset;
uniform int overlay_rotation:hint_range(-360,360);
uniform bool flip_overlay = false;
uniform bool backflip_overlay = false;
uniform bool overlay_world_pos = true;
uniform int front_mask_overlay:hint_range(-1,1);
uniform bool use_back_mask_overlay = false;
uniform int back_mask_overlay:hint_range(-1,1);

group_uniforms Lighting;
uniform sampler2D lightmap:hint_default_white,filter_nearest;
uniform vec2 lightmap_size = vec2(1.0);
uniform vec2 lightmap_offset = vec2(0.0);

varying vec3 world_position;
varying vec2 base_uv;
varying vec3 world_normal;

varying vec3 norm_normal;
varying vec3 abs_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(mat3(MODEL_MATRIX) * NORMAL);
	base_uv = UV;
}

vec2 uv_calc(float scale, sampler2D albedo_in, vec2 offset, bool world_pos,int rot, bool frontface) {
	vec2 texsize = vec2(textureSize(albedo_in,0));
	vec2 ratio = vec2(1.0,texsize.x/texsize.y);
	float top_weight = pow(abs_normal.y, blend_sharpness);
	float side_x_weight = pow(abs_normal.x, blend_sharpness);
	float side_z_weight = pow(abs_normal.z, blend_sharpness);
	float total_weight = top_weight + side_x_weight + side_z_weight;
	
	vec2 uv_top = world_position.xz / -scale * ratio;
	vec2 uv_side_x = world_position.zy / -scale * ratio;
	vec2 uv_side_z = world_position.xy / -scale * ratio;
	// If any of these values are off, assume normals got distorted from rotation and correct accordingly!
	if (world_normal.y < 0.0){ // If the normal's x or y is less than 0, assume it's flipped incorrectly
		uv_top.y = -uv_top.y;
	}
	if (world_normal.x < 0.0){
		uv_side_x.x = -uv_side_x.x;
	}
	if (world_normal.z > 0.0){ // If the normal.z is less than 0, assume it's flipped incorrectly
		uv_side_z.x = -uv_side_z.x;
	}
	vec2 result = (top_weight > side_x_weight && top_weight > side_z_weight) ? uv_top :
		(side_x_weight > side_z_weight) ? uv_side_x : uv_side_z;
	result = mix(base_uv,result,float(world_pos)); // Use world_pos as toggle between base_uv and world_pos uv
	result += offset / texsize;
	// Convert degree integer to a float in radians
	float rad = radians(float(rot));
	// Calculate sine and cosine of the angle
	float sin_angle = sin(rad);
	float cos_angle = cos(rad);
	// apply sine and cosine
	result = vec2(result.x * cos_angle - result.y * sin_angle,result.x * sin_angle + result.y * cos_angle);
	if (!frontface && fix_back){ // Fix back if back-facing and fix_back is enabled
		result.x = -result.x;
	}
	if (flip_texture){
		result.x = -result.x;
	}
	return result;
}

vec4 create_full_albedo(sampler2D albedo_tex, vec2 given_uv,int mask,vec4 mask_albedo, vec4 modcolor, vec4 fragcoord){
	vec4 result_albedo = texture(albedo_tex, given_uv);
	if (mask == 1){
		result_albedo.a *= mask_albedo.r + mask_intensity;
	} else if (mask == -1){
		result_albedo.a *= 1.0 - mask_albedo.r - mask_intensity;
	}
	result_albedo *= modcolor;
	return result_albedo;
}

void fragment() {
	if (!render_front && FRONT_FACING){ //Discard if render front or render back are disabled
		discard;
	}
	if (!render_back && !FRONT_FACING){
		discard;
	}
	norm_normal = normalize(world_normal);
	abs_normal = abs(norm_normal);
	float top_weight = pow(abs_normal.y, blend_sharpness);
	float side_x_weight = pow(abs_normal.x, blend_sharpness);
	float side_z_weight = pow(abs_normal.z, blend_sharpness);
	float total_weight = top_weight + side_x_weight + side_z_weight;
	top_weight /= total_weight;
	side_x_weight /= total_weight;
	side_z_weight /= total_weight;
	vec2 uv = uv_calc(tile_scale,texture_albedo,texture_offset,tex_world_pos,rotation_degrees,FRONT_FACING);
	// repeat process for mask
	vec2 mask_uv = uv_calc(mask_scale,mask_texture,mask_offset,mask_world_pos,mask_rotation,FRONT_FACING);
	if (mask_back_flip && !FRONT_FACING){
		mask_uv.x = -mask_uv.x;
	}
	// repeat process for overlay
	vec2 overlay_uv = uv_calc(overlay_scale,overlay_texture,overlay_offset,overlay_world_pos,overlay_rotation,FRONT_FACING);
	if (backflip_overlay && !FRONT_FACING){
		overlay_uv.x = -overlay_uv.x;
	}
	// Set up final albedos, get ready to set colors
	vec4 final_mask = texture(mask_texture,mask_uv);
	int final_overlay_mask = front_mask_overlay;
	if (!FRONT_FACING && use_back_mask_overlay){
		final_overlay_mask = back_mask_overlay;
	}
	vec4 base = create_full_albedo(texture_albedo, uv,1,final_mask,modulate,FRAGCOORD);
	vec4 over = create_full_albedo(overlay_texture, overlay_uv,final_overlay_mask,final_mask,overlay_modulate,FRAGCOORD);
	vec4 final_albedo;
	final_albedo = base;
	if (base.a == 0.0 && final_overlay_mask == 1) {
		final_albedo = vec4(0.0);     
    } else if (over.a == 0.0)  {
		final_albedo = base;     
	} else { 
		final_albedo = over;     
	}
	// Handle dithered transparency
	ivec2 dither_size = textureSize(dither_tex, 0);
	vec2 f_dither_size = vec2(1.0 / float(dither_size.x), 1.0 / float(dither_size.y)) * vec2(1.0 / dither_scale);
	vec2 dither_uv = FRAGCOORD.xy * f_dither_size;
	float dither_threshold = texture(dither_tex, dither_uv).r;
	if (final_albedo.a < 0.001 || final_albedo.a < dither_threshold) {
		discard;
	}
	// Handle lighting
	vec2 actual_lightmap_size = vec2(1.0) / lightmap_size;
	vec4 light = texture(lightmap,(world_position.xz * actual_lightmap_size) + lightmap_offset);
	ALBEDO = final_albedo.rgb * light.rgb;
}