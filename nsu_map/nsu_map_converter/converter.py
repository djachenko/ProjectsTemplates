import json


def checkType(point: dict) -> bool:
    id = point["id"]
    type_ = point["type"]

    id_lenght = len(id)

    if id_lenght == 4:
        return type_ == "endpoint"

    if id_lenght == 3:
        return type_ == "waypoint"

    if id_lenght == 6:
        return type_ == "endpoint"

    return False


def check_id(point: dict) -> bool:
    return point["id"].isdigit()


def check_has_postfix(point: dict) -> bool:
    return point["id"][-2] == "_" or point["type"] == "waypoint"


def check_valid_postfix(point: dict):
    return point["type"] == "waypoint" or point["id"].rsplit("_")[1] in ["m", "l", "p"]


def check(point: dict) -> bool:
    return all([
        checkType(point),
        # check_id(point),
        check_has_postfix(point),
        check_valid_postfix(point)
    ])


def main():
    with open("main_complex.json") as roomsFile:
        rooms_list = json.load(roomsFile)

        check_results = [check(room) for room in rooms_list]

        # check_result = all(check_results)

        failed_points = [point for res, point in zip(check_results, rooms_list) if not res]
        successful_points = [point for res, point in zip(check_results, rooms_list) if res]

        # special_rooms = [room for room in rooms_list if len(room["id"]) == 6]

        counter = {}

        neighbours_mapper = []
        id_mapper = {}

        new_map = {
            "points": {
                "building_new": {}
            }

        }

        for point in rooms_list:
            neighbors = point["neighbors"].split(" ")

            neighbours_mapper += [(neighbor, point["id"]) for neighbor in neighbors]

        for point in successful_points:
            name_length = len(point["id"])

            if name_length == 6:
                subtype_id = int(point["id"][3])

                prefix = [
                    "stair",
                    "diner",
                    "toilet",
                    "elevator",
                    "disabledToilet",
                ][subtype_id]
            else:
                templates = ["" for _ in range(3)] + [
                    "waypoint",
                    "room"
                ]

                prefix = templates[name_length]

            exceptions = [
                "1323/1",
                "1112/1"
            ]

            if point["id"] in exceptions:
                prefix = "room"

            if prefix == "room":
                point_id = prefix + "_" + point["id"]
            else:
                if point["floor"] not in counter:
                    counter[point["floor"]] = {}

                point_number = counter[point["floor"]].get(prefix, 0) + 1

                point_id = prefix + "_" + str(point_number)

                counter[point["floor"]][prefix] = point_number

            new_point = {
                "id": point_id,
                "name": point["id"],
                "posX": point["posX"],
                "posY": point["posY"],
                "type": prefix,
            }

            floor_id = "floor_" + str(point["floor"])

            point_full_id = ".".join([
                "building_new",
                floor_id,
                point_id
            ])

            id_mapper[point["id"]] = point_full_id

            floor = new_map["points"]["building_new"].get(floor_id, [])

            floor.append(new_point)

            new_map["points"]["building_new"][floor_id] = floor

        sorted_mapper = sorted(neighbours_mapper, key=lambda x: x[1])
        sorted_mapper = sorted(sorted_mapper, key=lambda x: x[0])

        non_paired_mapper = [(a, b) for a, b in neighbours_mapper if (b, a) not in neighbours_mapper]

        filtered_mapper = []

        for a, b in sorted_mapper:
            if (b, a) not in filtered_mapper:
                filtered_mapper.append((a, b))

        graph = []

        for a, b in filtered_mapper:
            if a in id_mapper and b in id_mapper:
                graph.append(
                    (
                        id_mapper[a],
                        id_mapper[b]
                    )
                )

        a = 7

        new_map["graph"] = graph

        with open("main_complex_new.json", "w") as new_rooms:
            json.dump(new_map, new_rooms, indent=4)

        newDict = {
            "new.json": rooms_list
        }


if __name__ == '__main__':
    main()
