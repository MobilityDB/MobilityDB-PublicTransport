import google.protobuf.json_format as json_format
import google.protobuf.text_format as text_format
import json

import gtfs_realtime_pb2 as rt



f = open('../NY-LIRR-rt.txt')
raw_lines = f.readlines()
lines=[]

print("[INFO] - Removing lines containing attribute 1005")
for line in raw_lines:
	if "1005: \"" not in line:
		lines.append(line)

print("[INFO] - Remove complete")



message = text_format.Parse(''.join(lines),rt.FeedMessage())
f.close()

data = json.loads(json_format.MessageToJson(message))

print("[INFO] - Writing CSV")
j=0
rt_output = open("vehicle_positions.csv", "w")
rt_output.write("tripID, vehicleID, latitude, longitude\n")

for dic in data["entity"]:
	if "vehicle" in dic:
		curr_v = data["entity"][j]["vehicle"]
		s = curr_v["trip"]["tripId"] + "," + curr_v["vehicle"]["id"]+","+\
		    str(curr_v["position"]["latitude"]) + "," + str(curr_v["position"]["longitude"])+"\n"
		rt_output.write(s)
	j+=1
rt_output.close()

print("[INFO] - CSV writed")