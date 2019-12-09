import json


def main():
    with open("rooms.json") as old_json:
        old_rooms = json.load(old_json)

    with open("new_rooms.json") as new_json:
        new_map = json.load(new_json)

    new_rooms = []

    for building in new_map["points"]:
        for floor in new_map["points"][building]:
            for point in new_map["points"][building][floor]:
                point_id = ".".join([building, floor, point["id"]])

                point["id"] = point_id

                new_rooms.append(point)

    new_graph = new_map["graph"]

    new_graph = [(x[0], x[1]) for x in new_graph]

    room_mapping_id = {}
    old_room_mapping = {}

    for room_1 in old_rooms:
        for room_2 in old_rooms:
            if room_1 != room_2 and room_1["posX"] == room_2["posX"] and room_1["posY"] == room_2["posY"]:
                print("Rooms {0} and {1} have same coords".format(room_1["id"], room_2["id"]))

    for old_room in old_rooms:
        exists = False

        for new_room in new_rooms:
            new_room_floor = int(new_room["id"].split(".")[1].split("_")[1])

            if new_room["posX"] == old_room["posX"] and new_room["posY"] == old_room["posY"] and new_room_floor == old_room["floor"]:
                exists = True
                room_mapping_id[old_room["id"]] = new_room["id"]

                break

        if not exists:
            print("Room {0} does not exist".format(old_room))

    for old_room in old_rooms:
        old_room_id = old_room["id"]
        neighbors = old_room["neighbors"].split(" ")

        if old_room_id not in room_mapping_id:
            continue

        new_room_id = room_mapping_id[old_room_id]
        new_neighbors_ids = [room_mapping_id[neighbor_id] for neighbor_id in neighbors]

        for new_neighbors_id in new_neighbors_ids:
            if (new_room_id, new_neighbors_id) not in new_graph and (new_neighbors_id, new_room_id) not in new_graph:
                print("{0} and {1} should be connected".format(new_room_id, new_neighbors_id))


if __name__ == '__main__':
    main()
