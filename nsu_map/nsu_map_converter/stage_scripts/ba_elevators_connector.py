import json
from typing import List, Dict


def is_elevator(id_str: str) -> bool:
    return len(id_str) == 8 and id_str[:6].isdecimal() and id_str[3] == "3"


def cross_connect(graph: Dict[str, List[str]]):
    print("cc")

    for start in graph:

        added = True

        while added:
            neighbors_1 = graph[start]

            added = False

            for neighbor_1 in neighbors_1:
                neighbors_2 = graph[neighbor_1]

                for neighbor_2 in neighbors_2:
                    if neighbor_2 not in neighbors_1 and neighbor_2 != start and neighbor_2[0] != start[0]:
                        neighbors_1.append(neighbor_2)

                        print("con {0} {1}".format(start, neighbor_2))

                        added = True


def mirror(graph: Dict[str, List[str]]):
    for start in graph:
        neighbors = graph[start]

        for neighbor in neighbors:
            if start not in graph[neighbor]:
                print("mir {0} {1}".format(neighbor, start))

                graph[neighbor].append(start)


def run(file_name: str):
    with open("jsons/" + file_name + ".json") as roomsFile:
        points = json.load(roomsFile)

    id_mapping = {point["id"]: point for point in points}

    elevator_ids = [key for key in id_mapping.keys() if is_elevator(key)]

    elevators_connections = {}

    for elevator_id in elevator_ids:
        elevator = id_mapping[elevator_id]

        neighbors_string = elevator["neighbors"]

        neighbors_ids = neighbors_string.split(" ")

        neighbors_elevators = [i for i in neighbors_ids if is_elevator(i)]

        elevators_connections[elevator_id] = neighbors_elevators

    cross_connect(elevators_connections)

    mirror(elevators_connections)

    for elevator_id in elevators_connections:
        elevator = id_mapping[elevator_id]

        elevator_neighbors_str = elevator["neighbors"]

        elevator_neighbors = elevator_neighbors_str.split(" ")

        elevator_new_neighbors = elevators_connections[elevator_id]

        for neighbor in elevator_new_neighbors:
            if neighbor not in elevator_neighbors:
                elevator_neighbors.append(neighbor)

        elevator_neighbors_str = " ".join(elevator_neighbors)

        elevator["neighbors"] = elevator_neighbors_str

        id_mapping[elevator_id] = elevator

    points = list(id_mapping.values())

    with open("jsons/" + file_name + "_connected.json", "w") as merged:
        json.dump(points, merged, indent=4)
