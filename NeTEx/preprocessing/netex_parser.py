import xml.etree.ElementTree as et
from file_utils import *
from time import time
import sys

startPos='<gml:Point srsName="EPSG:2154"><gml:pos>'
endPos='</gml:pos></gml:Point>'

def parseRec(tree, fQuays, fDayTypes, fSJP, fOperators, fLine, fStopPlace, fServiceJourney
             ,fScheduledStopPoint, fStopAssi, fStopPointsInSeq):
	for child in tree:

		if str(child.tag) == "{http://www.netex.org.uk/netex}DayType":
			toWrite = extractID(child.attrib["id"]) + "\n"
			fDayTypes.write(toWrite)
		if str(child.tag) == "{http://www.netex.org.uk/netex}ServiceJourneyPattern":
			toWrite = extractID(child.attrib["id"]) + ","
			toWrite += child[0].text+"\n"
			fSJP.write(toWrite)
			for seqPoint in child[2]:
				toWrite2 = extractID(seqPoint.attrib["id"]) + ","  # id
				toWrite2 += seqPoint.attrib["order"] + ","  # order
				toWrite2 += extractID(seqPoint[0].attrib["ref"]) + ","  # scheduledStopPointRef
				if seqPoint[1].text == "true":
					toWrite2 += "1,"
				else:
					toWrite2 += "2,"

				if seqPoint[2].text == "true":
					toWrite2 += "1,"
				else:
					toWrite2 += "2,"
				toWrite2+=extractID(child.attrib["id"])+"\n"
				fStopPointsInSeq.write(toWrite2)
		if str(child.tag) == "{http://www.netex.org.uk/netex}Operator":
			toWrite = extractID(child.attrib["id"]) + ","
			toWrite += child[0].text + ","
			toWrite += child[1][0].text + ","
			toWrite += child[1][1].text + ","
			toWrite += child[2].text + "\n"
			fOperators.write(toWrite)
		if str(child.tag) == "{http://www.netex.org.uk/netex}Line":
			toWrite = extractID(child.attrib["id"]) + ","
			toWrite += child[0].text + ","
			toWrite += child[1].text + ","
			toWrite += child[2].text + "\n"
			fLine.write(toWrite)
		if str(child.tag) == "{http://www.netex.org.uk/netex}StopPlace":
			toWrite = extractID(child.attrib["id"]) + "," # id
			toWrite += child[0].text + "," # name
			toWrite += startPos+child[1][0][0].text+endPos + "," # location
			for subChild in child:
				if str(subChild.tag) == "{http://www.netex.org.uk/netex}quays":
					toWrite += extractID(subChild[0].attrib["id"])
					quaytoWrite = extractID(subChild[0].attrib["id"]) + ","
					quaytoWrite += subChild[0][0].text + ","
					quaytoWrite += subChild[0][1][0][0].text + "\n"
					fQuays.write(quaytoWrite)
			fStopPlace.write(toWrite+"\n")
		if str(child.tag) == "{http://www.netex.org.uk/netex}ServiceJourney":
			toWrite = extractID(child.attrib["id"]) + "," # id
			toWrite += extractID(child[0][0].attrib["ref"]) + "," # daytypeRef
			toWrite += extractID(child[1].attrib["ref"]) + "," # serviceJourneyPatternRef
			toWrite += extractID(child[2].attrib["ref"]) + "\n"
			fServiceJourney.write(toWrite)
		if str(child.tag) == "{http://www.netex.org.uk/netex}ScheduledStopPoint":
			toWrite = extractID(child.attrib["id"]) + "," #id
			toWrite += child[0][0].text + "\n"  # location
			fScheduledStopPoint.write(toWrite)
		if str(child.tag) == "{http://www.netex.org.uk/netex}PassengerStopAssignment":
			toWrite = extractID(child.attrib["id"]) + "," #id
			toWrite += child.attrib["order"] + "," #order
			toWrite += extractID(child[0].attrib["ref"]) + "," #scheduledStopPointRef
			toWrite += extractID(child[1].attrib["ref"]) + "," #stopPlaceRef
			toWrite += extractID(child[2].attrib["ref"]) + "\n" #quayRef
			fStopAssi.write(toWrite)







		parseRec(child,fQuays, fDayTypes, fSJP, fOperators, fLine, fStopPlace, fServiceJourney,
		         fScheduledStopPoint, fStopAssi, fStopPointsInSeq)



if __name__ == "__main__":
    # Vérification of arguments
    if len(sys.argv) != 3:
        print("Usage: python3 netex_parser.py netex_epip_file.xml output_directory")
    else:
        output_directory = sys.argv[2]

        if not os.path.isdir(output_directory):
            print("Error: The output directory is not a valid directory.")
            sys.exit(1)
        print("[INFO] - Parsing XML file...")
        t1 = time()
        tree = et.parse(sys.argv[1])
        print("[INFO] - Ended parsing XML file after", round(time() - t1),"seconds.")
        root = tree.getroot()



    print("[INFO] - Opening output files...")
    fQuays, fDayTypes, fSJP, fOperators, fLine, fStopPlace, fServiceJourney\
    	, fScheduledStopPoint, fStopAssi, fStopPointsInSeq = openAllFiles(output_directory)
    print("[INFO] - writing output files...")
    parseRec(root, fQuays, fDayTypes, fSJP, fOperators, fLine, fStopPlace,fServiceJourney,fScheduledStopPoint, fStopAssi
             ,fStopPointsInSeq)
    print("[INFO] - closing output files...")
    closeAllFiles(fQuays, fDayTypes, fSJP, fOperators, fLine, fStopPlace,fServiceJourney, fScheduledStopPoint, fStopAssi
                  ,fStopPointsInSeq)
