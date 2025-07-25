import os
import osmnx as ox
from osmnx import settings

def osm_graphml_downloader(network_type,
        out_dir,
        filename = None,
        bbox = None,
        custom_filter = None,
        reproject = False,
        epsg_code = None,
        simplify = False):
    
    network_type_list = ["walk", "bike", "drive", "drive_service", "all", "all_private", "none"]
    if network_type not in network_type_list:
        raise ValueError("results: status must be one of %r." % network_type_list)

    if custom_filter is not None:
        custom_filter = (custom_filter).format(settings.default_access)

    if filename is None:
        filename = f'graph_{network_type}.graphml'
    else:
        filename_no_extension = filename.split('.')[0]
        filename = f'{filename_no_extension}.graphml'

    outgraph = os.path.join(out_dir, filename)

    print("Downloading and generating graph from OSM...")
    graph = ox.graph_from_bbox(bbox[3], bbox[1], bbox[2], bbox[0], network_type = network_type, custom_filter = custom_filter, simplify = simplify)

    if reproject:
        if epsg_code:
            print(f"Reprojecting to {epsg_code}...")
            epsg_string = f'epsg:{epsg_code}'
        else:
            print(f"Reprojecting to UTM...")
            epsg_string = None
        graph = ox.project_graph(graph, to_crs = epsg_string)
    
    print("Saving graph...")
    ox.save_graphml(graph, outgraph)

    print(f"Graph saved: {outgraph}")