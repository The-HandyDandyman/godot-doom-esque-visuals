extends Node
var stored_lightmaps:Array[ImageTexture]

func generate_tile_lightmap(tiles:GridMap):
	if tiles == null: return
	var newImg:Image = Image.create(512,512,false,Image.FORMAT_RGBA8)
	newImg.fill(Color.GREEN)
	var newImageTex:ImageTexture = ImageTexture.create_from_image(newImg)
	stored_lightmaps.append(stored_lightmaps)
	for item_id in tiles.mesh_library.get_item_list():
		var mesh:Mesh = tiles.mesh_library.get_item_mesh(item_id)
		if mesh == null: return
		for surf_idx in range(mesh.get_surface_count()):
			var selected_material:Material = mesh.surface_get_material(surf_idx)
			if selected_material == null: return
			if selected_material is ShaderMaterial:
				selected_material.set_shader_parameter("lightmap",newImageTex)
	return newImageTex
