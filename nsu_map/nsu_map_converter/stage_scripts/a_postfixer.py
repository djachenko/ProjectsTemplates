import json


def run(file_name: str, postfix: str = ""):
    with open("jsons/" + file_name + "_connected.json") as roomsFile:
        points = json.load(roomsFile)

    postfixes = ["_" + i for i in ["m", "p", "l", "n", "r"]]

    id_mapping = {}

    for point in points:
        point_id = point["id"]

        if not any([point_id.endswith(postfix) for postfix in postfixes]):
            print(point_id)

            point_id += postfix

        id_mapping[point["id"]] = point_id

    for point in points:
        neighbors = [s for s in list(set(point["neighbors"].split(" "))) if s]

        new_neighbors = [id_mapping[neighbor] for neighbor in neighbors]

        new_neighbors_string = " ".join(new_neighbors)
        new_id = id_mapping[point["id"]]

        point["id"] = new_id
        point["neighbors"] = new_neighbors_string

    with open("jsons/" + file_name + "_postfixes_fixed.json", "w") as merged:
        json.dump(points, merged, indent=4)


if __name__ == '__main__':
    run("very final")
