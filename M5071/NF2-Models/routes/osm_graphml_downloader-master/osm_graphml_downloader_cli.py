from time import perf_counter
start = perf_counter()

import os
import shutil
import gzip
import click
from datetime import timedelta
from osm_graphml_downloader import osm_graphml_downloader

@click.command()
@click.option('-x', '--network_type', help = 'Network type: "walk", "bike", "drive", "drive_service", "all", "all_private", "none"')
@click.option('-o', '--out_dir', help = 'Path to directory where you want the results to go')
@click.option('-f', '--filename', default = None, help = 'Name of .graphml ouput file')
@click.option('-n', '--north', help = 'Area of interest north extent', type = float)
@click.option('-s', '--south', help = 'Area of interest south extent', type = float)
@click.option('-e', '--east', help = 'Area of interest east extent', type = float)
@click.option('-w', '--west', help = 'Area of interest west extent', type = float)
@click.option('--custom_filter', help = 'Custom filter')
@click.option('--reproject', is_flag = True, help = 'Option to reproject the graph from WGS84 to something else')
@click.option('--epsg_code', help = 'EPSG code value. Only used if --reproject flag is used')
@click.option('--simplify', is_flag = True, help = 'Option to download a simplified network.')
@click.option('--compress', is_flag = True, help = 'Compress final output using gzip.')
def main(network_type, out_dir, filename, north, south, east, west, custom_filter, reproject, epsg_code, simplify, compress):
    if epsg_code is not None:
        epsg_code = int(epsg_code)
    osm_graphml_downloader(network_type = network_type,
                         out_dir = out_dir,
                         filename = filename,
                         bbox = [west, south, east, north],
                         custom_filter = custom_filter,
                         reproject = reproject,
                         epsg_code = epsg_code,
                         simplify = simplify)
    
    if compress:
        print("Compressing results...")
        if filename is None:
            filename = f'graph_{network_type}.graphml'
        else:
            filename_no_extension = filename.split('.')[0]
            filename = f'{filename_no_extension}.graphml'
        print('filename:', filename)
        downloaded_graph = os.path.join(out_dir, filename)
        print('downloaded_graph:', downloaded_graph)

        try:
            with open(downloaded_graph, 'rb') as f_in:
                with gzip.open(f"{downloaded_graph}.gz", 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
            os.remove(downloaded_graph)
        except Exception as e:
            print(e)

    end = perf_counter()
    completion_seconds = end - start
    print(f"Elapsed time: {timedelta(seconds = completion_seconds)}")

if __name__ == "__main__":
    main()