import json


def main():
    names = [
        "main_building",
        "lab_building",
        "perehod"
    ]

    points = []

    for name in names:
        with open(name + "_merged.json") as roomsFile:
            points += json.load(roomsFile)

    id_mapping = {}
    waypoints_counter = 0

    for point in points:
        point_id = point["id"]

        if point["type"] == "waypoint":
            floor = point["floor"]

            id_mapping[point_id] = "waypoint_" + str(waypoints_counter)
            waypoints_counter += 1
        else:
            id_mapping[point_id] = point_id

    for point in points:

        neighbors = [s for s in list(set(point["neighbors"].split(" "))) if s]

        new_neighbors = [id_mapping[neighbor] for neighbor in neighbors]

        new_neighbors_string = " ".join(new_neighbors)
        new_id = id_mapping[point["id"]]

        point["id"] = new_id
        point["neighbors"] = new_neighbors_string

    with open("final_merged.json", "w") as merged:
        json.dump(points, merged, indent=4)


if __name__ == '__main__':
    main()
