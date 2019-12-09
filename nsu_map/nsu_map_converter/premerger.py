import json


def main():
    name = "main_building"

    with open(name + ".json") as roomsFile:
        points = json.load(roomsFile)

    id_mapping = {}

    points = [point for point in points if point["id"]]

    for point in points:
        point_id = point["id"]

        old_point_id = point_id

        if point_id.endswith("_m"):
            point_id = point_id.rsplit("_", 1)[0]

        if point["type"] == "waypoint":
            point_id = "waypoint_" + point_id

        point_id += "_" + name[0]

        id_mapping[old_point_id] = point_id

    assert len(id_mapping.values()) == len(set(id_mapping.values()))

    for point in points:


        neighbors = [s for s in list(set(point["neighbors"].split(" "))) if s]

        if "" in neighbors:
            a = 7

        new_neighbors = [id_mapping[neighbor] for neighbor in neighbors]

        new_neighbors_string = " ".join(new_neighbors)
        new_id = id_mapping[point["id"]]

        point["id"] = new_id
        point["neighbors"] = new_neighbors_string

    with open(name + "_merged.json", "w") as merged:
        json.dump(points, merged, indent=4)


if __name__ == '__main__':
    main()
