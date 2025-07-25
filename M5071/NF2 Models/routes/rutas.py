import osmnx as ox
import taxicab as tc

# Load the graph
G = ox.load_graphml("manhatten.graphml")
origin_coordinates = (40.70195053163349, -74.01123198479581)
destination_coordinates = (40.87148739347057, -73.91517498611597)
route = tc.distance.shortest_path(G, origin_coordinates, destination_coordinates)
tc.plot.plot_graph_route(G, route)