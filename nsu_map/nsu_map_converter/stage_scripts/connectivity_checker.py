import json
from typing import List, Dict, Set, Tuple


def floyd(w: Set[Tuple[str, str]]):
    points = set()

    for a, b in w:
        points.add(a)
        points.add(b)

    print(len(points))

    count = 0

    for k in points:
        print(count, k)

        count += 1

        append_count = 0

        for i in points:
            for j in points:
                if (i, j) not in w:
                    if (i, k) in w and (k, j) in w:
                        w.add((i, j))

                        append_count += 1

        print(append_count, len(w))


def run():
    with open("jsons/final.json") as roomsFile:
        data = json.load(roomsFile)

    graph = set()

    def add_to_graph(a, b):
        graph.add((a, b))

    for start, finish in data["graph"]:
        add_to_graph(start, finish)
        add_to_graph(finish, start)

    floyd(graph)

    all_points = data["points"]

    for building_name, building in all_points.items():
        points = []

        for floor_name, floor in building.items():
            for point in floor:
                if point["type"] != "room":
                    continue

                point_name = point["id"]

                full_id = ".".join([building_name, floor_name, point_name])

                points.append(full_id)

        for point in points:
            if point not in graph:
                print("{0} is absent".format(point))

        for point_a in points:
            for point_b in points:
                if point_a == point_b:
                    continue

                if (point_a, point_b) not in graph:
                    print("{0} not acc from {1}".format(point_b, point_a))

                if (point_b, point_a) not in graph:
                    print("{0} not acc from {1}".format(point_a, point_b))


if __name__ == '__main__':
    run()
