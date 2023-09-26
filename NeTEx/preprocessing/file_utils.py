import os

def openAllFiles(output_directory):
	if not os.path.exists(output_directory):
		os.makedirs(output_directory)
		print("[INFO] - Output directory created")
	else:
		print("[INFO] - Output directory already existing")

	fQuays = open(output_directory + "/quays.txt", "w")
	fQuays.write("id, name, centroid\n")

	fDayTypes = open(output_directory + "/dayTypes.txt", "w")
	fDayTypes.write("id\n")

	fSJP = open(output_directory + "/serviceJourneyPatterns.txt", "w")
	fSJP.write("id, distance\n")

	fOperators = open(output_directory + "/operators.txt", "w")
	fOperators.write("id, name, phone, url, organisationType\n")

	fLine = open(output_directory + "/lines.txt", "w")
	fLine.write("id, name, transportMode, publiccode\n")

	fStopPlace = open(output_directory + "/stopPlaces.txt", "w")
	fStopPlace.write("id, name, centroid_val, quayID\n")

	fServiceJourney = open(output_directory + "/serviceJourneys.txt", "w")
	fServiceJourney.write("id, dayTypeRef, ServiceJourneyPatternRef, operatorRef\n")


	fScheduledStopPoint = open(output_directory + "/scheduledStopPoints.txt", "w")
	fScheduledStopPoint.write("id, location_val\n")

	fStopAssi = open(output_directory + "/stopAssignments.txt", "w")
	fStopAssi.write("id, order, scheduledStopPointRef, stopPlaceRef, QuayRef\n")

	fStopPointsInSeq = open(output_directory + "/stopPointsInSequence.txt", "w")
	fStopPointsInSeq.write("id, order, scheduledStopPointRef, forAlighting, forBoarding, journeyPatternRef\n")

	return fQuays, fDayTypes, fSJP, fOperators, fLine, fStopPlace, fServiceJourney, fScheduledStopPoint, fStopAssi\
		, fStopPointsInSeq

def closeAllFiles(*files):
	for file in files:
		file.close()

def extractID(text):
	first = text.index(":")
	second = text.index(":", first+1)
	return text[second+1:-1]