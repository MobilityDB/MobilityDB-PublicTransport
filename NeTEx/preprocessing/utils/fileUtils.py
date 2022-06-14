import os

def openAllFiles():
	if not os.path.exists("../netex-csvs"):
		os.makedirs("../netex-csvs")
		print("[INFO] - Output directory created")
	else:
		print("[INFO] - Output directory already existing")

	fQuays = open("../netex-csvs/quays.txt", "w")
	fQuays.write("id, name, centroid\n")

	fDayTypes = open("../netex-csvs/dayTypes.txt", "w")
	fDayTypes.write("id\n")

	fSJP = open("../netex-csvs/serviceJourneyPatterns.txt", "w")
	fSJP.write("id, distance\n")

	fOperators = open("../netex-csvs/operators.txt", "w")
	fOperators.write("id, name, phone, url, organisationType\n")

	fLine = open("../netex-csvs/lines.txt", "w")
	fLine.write("id, name, transportMode, publiccode\n")

	fStopPlace = open("../netex-csvs/stopPlaces.txt", "w")
	fStopPlace.write("id, name, centroid_val, quayID\n")

	fServiceJourney = open("../netex-csvs/serviceJourneys.txt", "w")
	fServiceJourney.write("id, dayTypeRef, ServiceJourneyPatternRef, operatorRef\n")


	fScheduledStopPoint = open("../netex-csvs/scheduledStopPoints.txt", "w")
	fScheduledStopPoint.write("id, location_val\n")

	fStopAssi = open("../netex-csvs/stopAssignments.txt", "w")
	fStopAssi.write("id, order, scheduledStopPointRef, stopPlaceRef, QuayRef\n")

	fStopPointsInSeq = open("../netex-csvs/stopPointsInSequence.txt", "w")
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
