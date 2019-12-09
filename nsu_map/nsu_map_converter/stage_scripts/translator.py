import csv
import json


def run():
    with open("jsons/final.json") as roomsFile:
        mapping = json.load(roomsFile)

    points_obj = mapping["points"]

    headers = [
        "id",
        "en",
        "ru",
    ]

    rows = []

    for building_id in points_obj:
        if building_id == "building_new":
            pass

        building = points_obj[building_id]

        for floor_id in building:
            floor = building[floor_id]

            for point in floor:
                if point["type"] == "waypoint":
                    continue

                point_id = point["id"]
                point_name = str(point["name"])

                full_id = ".".join([
                    building_id,
                    floor_id,
                    point_id
                ])

                english_name = point_name.split("_")[0]
                russian_name = english_name.replace("a", "а").replace("b", "б").replace("k", "к")

                row = {
                    "id": full_id,
                    "en": english_name,
                    "ru": russian_name,
                }

                rows.append(row)

    with open("csvs/temp.csv", "w") as final_file:
        writer = csv.DictWriter(final_file, fieldnames=headers)

        writer.writeheader()

        for row in rows:
            writer.writerow(row)


if __name__ == '__main__':
    run()
