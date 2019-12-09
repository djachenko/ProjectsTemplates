import json


def run(file_name: str):
    with open("jsons/{0}_postfixes_fixed.json".format(file_name)) as roomsFile:
        rooms_list = json.load(roomsFile)

    type_names = [
        "stair",
        "diner",
        "toilet",
        "elevator",
        "disabledToilet",
        "cloakroom",
        "qr"
    ]

    type_counters = {x: {i: 0 for i in range(7)} for x in (type_names + ["waypoint"])}

    full_id_mapping = {}

    building = {}
    building_id = "building_" + file_name

    for point in rooms_list:
        room_name = ""

        point_id = point["id"]

        if point["type"] == "waypoint":
            type_name = "waypoint"
        else:
            id_components = point_id.rsplit("_", 1)

            name = id_components[0]

            if name.isdigit() and len(name) == 6:
                type_char = int(name[3])

                type_name = type_names[type_char]
            else:
                type_name = "room"
                room_name = point_id

        floor = point["floor"]

        if type_name != "room":
            room_name = type_counters[type_name][floor]

            type_counters[type_name][floor] += 1

        room_id = "{type}_{name}".format(type=type_name, name=room_name)
        floor_id = "floor_" + str(floor)
        full_id = ".".join([
            building_id,
            floor_id,
            room_id
        ])

        if type_name == "qr":
            print(full_id, point_id)

        full_id_mapping[point_id] = full_id

        new_point = {
            "id": room_id,
            "name": room_name,
            "posX": point["posX"],
            "posY": point["posY"],
            "type": type_name
        }

        if floor_id not in building:
            building[floor_id] = []

        building[floor_id].append(new_point)

    graph = []

    for room in rooms_list:
        neighbors_string = room["neighbors"]

        neighbors = neighbors_string.split(" ")

        current_new_id = full_id_mapping[room["id"]]
        neighbors_new_ids = [full_id_mapping[neighbor] for neighbor in neighbors]

        new_edges = [(current_new_id, neighbor_new_id) for neighbor_new_id in neighbors_new_ids]

        for (from_point, to_point) in new_edges:
            if (from_point, to_point) in graph:
                continue

            if (to_point, from_point) in graph:
                continue

            graph.append((from_point, to_point))

    new_map = {
        building_id: building,
        "graph": graph
    }

    with open("jsons/{0}_converted.json".format(file_name), "w") as new_rooms:
        json.dump(new_map, new_rooms, indent=4)


if __name__ == '__main__':
    run()
