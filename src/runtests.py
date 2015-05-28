#!/usr/bin/python

import string
import datetime
import re
import sys
import os
import subprocess
import cgi
from xml.dom.minidom import parseString
from xml.parsers.expat import ExpatError
from xml.etree.ElementTree import ElementTree, Element, SubElement, tostring
import xml.etree.ElementTree as ET

today = datetime.date.today() 

# creates an empty file
def write_data_on_file(data, file_name):
    file = open(file_name, 'w')
    file.write(data)
    file.close


# generate HTML report from XML
def makeHTMLReport(xml):
    HTML = "<html> <body>"
    nPassed = xml.find('tot-passed').text
    HTML += "Passed: " + nPassed  + "<br>" 
    nFailed = xml.find('tot-failed').text
    HTML += "Failed: " + nFailed  + "<br>" 
    nNotSupported = xml.find('tot-not-supported').text
    HTML += "Not Supported: " + nNotSupported  + "<br>" 
    nManualReview = xml.find('tot-manual-review').text
    HTML += "Need manual review: " + nManualReview + "<br>" 
    nNoExpectedResult = xml.find('tot-no-result-file').text
    HTML += "Missing expected result: " + nNoExpectedResult  + "<br>" 

    nParserIssue = xml.find('tot-parser-issue').text
    HTML += "Parsing issues: " + nParserIssue  + "<br>" 

    nRegressions = xml.find('tot-regressions').text
    HTML += "Regressions: " + nRegressions  + "<br>"     
    test_categories = ['regressions', 'passed', 'failed', 'not-supported', 'manual-review', 'no-expected-result', "parser-issue"]
    for category in test_categories:
        HTML += "<h2>" + category + "</h2> <br>"
        HTML += XML2HTML(xml.find(category))
    HTML += "</body></html>"
    return HTML

def XML2HTML(xml):
    HTML = ""
    for test in xml:
        filename = test.find('fileName').text
        outcome = test.find('outcome').text
        result = test.find('result').text
        expected = test.find('expected').text
        kcell = test.find('k').text
        HTML += "<h4> <a href=" + filename  + ">" + filename + " </a></h4>"       
        HTML += "Outcome: " + outcome + "<br>" 
        HTML += "Result: " + result + "<br>" 
        HTML += "Expected: " + expected + "<br>" 
        HTML += "K Cell: " + kcell + "<br> <br>" 
    return HTML



# reads a file and return its content

# TODO: it's always good to have the try catch below. But I actually added because
#       of another issue: when a file is given to krun and it causes problem 
#       (mainly parsing problems), it seems krun no longer exits with exit code 1
#       and this means the subprocess throw no exception. The execution is not stopped
#       and later on we end up reading a non-existing file. Hence why I added this fix here. 
#       Again, this is good, but we should actually catch *that* error at the source, and 
#       not here, where it might actually be confused with other kind of errors. 

def get_file_content(filename):
    try:
        f = open(filename, "r")
        file_content = f.read()
        f.close()
        return file_content
    except: 
        return ""



def file_outcome(test_file, outcome, result, expected, kcell):
    # generate XML elements
    testResult = Element('test')
    fileNameTag = Element('fileName')
    outcomeTag = Element('outcome')
    resultTag = Element('result')
    expectedTag = Element('expected')
    kcellTag = Element('k')
    # append to the root
    testResult.append(fileNameTag)
    testResult.append(outcomeTag)
    testResult.append(resultTag)
    testResult.append(expectedTag)
    testResult.append(kcellTag)
    # fill in the data
    fileNameTag.text = test_file
    outcomeTag.text = str(outcome)    
    resultTag.text = result
    expectedTag.text = expected
    kcellTag.text = kcell
    # return node
    return testResult

def get_list_of_rules():
    list_of_rules = {}
    list_filename = "rules-list.txt"
    flist = open(list_filename)
    rules = flist.read().split("\n")
    for rule in rules:
        if rule in list_of_rules:
            print ("DUPLICATED: " + rule + "\n")
        list_of_rules[rule] = 0
    return list_of_rules

# run all the tests in a folder
def test_folder(dirname):
    passed = 0
    failed = 0
    crashed = 0
    toreview = 0
    without_result_file = 0
    parser_issue = 0
    regressions = 0
    
    # create XML root
    root = Element('testResults')
    
    # create one node per category 
    rep_pass = Element('passed')
    root.append(rep_pass)    
    rep_fail = Element('failed')
    root.append(rep_fail)        
    rep_crash = Element('not-supported')
    root.append(rep_crash)        
    rep_review = Element('manual-review')
    root.append(rep_review)        
    rep_no_res = Element('no-expected-result')
    root.append(rep_no_res)        
    
    rep_parser_issue = Element('parser-issue')
    root.append(rep_parser_issue)        
    
    rep_regression = Element('regressions')
    root.append(rep_regression)        
    
    # create global info XML nodes
    nPassedTag = Element('tot-passed')
    root.append(nPassedTag)        
    nFailedTag = Element('tot-failed')
    root.append(nFailedTag)
    nNotSupportedTag = Element('tot-not-supported')
    root.append(nNotSupportedTag)
    nManualReviewTag = Element('tot-manual-review')
    root.append(nManualReviewTag)
    nNoResFileTag = Element('tot-no-result-file')
    root.append(nNoResFileTag)                    
    
    nParserIssueTag = Element('tot-parser-issue')
    root.append(nParserIssueTag)                    
    
    nRegression = Element('tot-regressions')
    root.append(nRegression)                                

    # get the list of files in the directory
    list_of_test_files = os.listdir(dirname)

    # determine if information about previous passes is available (to be used for regression test)
    regression_info_path = dirname + "/regression_data/last_passes.xml"
    regression_enabled = os.path.exists(regression_info_path)
    if (regression_enabled):
        print ("Parsing regression information...")
        previous_passes = []
        tree = ET.parse(regression_info_path)
        for item in (tree.getroot().find('passed')):
            previous_passes.append(item.find('fileName').text)
        print (previous_passes)
    else:
        print ("Regression information not found. Regression data will not be generated.")

    # init rule coverage
    
    global_coverage = get_list_of_rules()
    
    # iterate throuh the list of files
    for test_file in list_of_test_files:
        if test_file.endswith(".phpt"):            
            file_path = dirname + "/" + test_file
            [outcome, result, expected, kcell, local_coverage] = run_test(file_path)    

            # regression
            if (regression_enabled and outcome != "pass"):
                if (file_path in previous_passes):
                    regressions += 1
                    rep_regression.append(file_outcome(file_path, outcome, result, expected, kcell))                
            
            # rule coverage
            if local_coverage:
                for rule in local_coverage:
                    if not (rule in global_coverage):
                        global_coverage[rule] = 0
                    global_coverage[rule] += local_coverage[rule]
    
            if (outcome == "pass"):
                passed += 1
                rep_pass.append(file_outcome(file_path, outcome, result, expected, kcell))
            
            elif (outcome == "fail"):
                failed += 1
                rep_fail.append(file_outcome(file_path, outcome, result, expected, kcell))
            elif (outcome == "output_needs_manual_review"):
                toreview += 1
                rep_review.append(file_outcome(file_path, outcome, result, expected, kcell))
                #rep_review += file_outcome(file_path, outcome, result, expected, kcell)
                #BMK or no output here because output may be messy
            elif (outcome ==  "not_supported"):
                crashed += 1
                rep_crash.append(file_outcome(file_path, outcome, result, expected, kcell))
            elif (outcome ==  "parsing_issue"):
                parser_issue += 1
                rep_parser_issue.append(file_outcome(file_path, outcome, result, "-", "-"))
            elif (outcome == "no_result_file"):
                without_result_file += 1
                rep_no_res.append(file_outcome(file_path, outcome, result, expected, kcell))
    nPassedTag.text = str(passed)
    nFailedTag.text = str(failed)
    nNotSupportedTag.text = str(crashed)
    nManualReviewTag.text = str(toreview)
    nNoResFileTag.text = str(without_result_file)        
    nParserIssueTag.text = str(parser_issue)        
    
    nRegression.text = str(regressions)

    # write out coverage data
    coverage_file = "coverage.txt"
    coverage_data = dict_2_string(global_coverage)
    write_data_on_file(coverage_data, coverage_file)
    return root

def dict_2_string(d):
    result = ""
    for key in d:
        result += key + " : " + str(d[key]) + "\n"
    return result

# parse a phpt file, and return a dictionary containing all the fields
def parse_phpt_file(file_name):
    file_content = get_file_content(file_name)
    splitted_file = re.split('--(TEST|FILE|FILEOF|EXPECT|EXPECTF|EXPECTREGEX|EXPECTSIGNS|EXPECTTYPES|INI|SKIPIF|FILEOF|GET|POST|POST_RAW)--' , file_content)
    del splitted_file[0]
    test = {}
    for i in range (0, len(splitted_file) - 1):
        test[splitted_file[i]] = splitted_file[i + 1]
        i = i + 1
    return test

def fromScanfStyleToRegexp(input):
    return input.replace("(", '\\(').replace(")", '\\)').replace("%d", "(\d+)").replace("%i", "(\d+)")
               
# run a single test
def run_test(filename):

    # load a phpt file and parse and return a dictionary containing its fields (TEST, EXPECT, etc.)
    crnt_test = parse_phpt_file(filename)
    print ("Running: " + filename + "...")
    errorcode = 0
    residual = ".K"

    # check if the current test uses GET or POST, that are not currently supported.
    # If that's the case we directly return without even running the test.
    if ('GET' in crnt_test or 'POST' in crnt_test or 'POST_RAW' in crnt_test):
        outcome = "not_supported"
        print ("=> " + outcome)
        return [outcome, "KPHP ERROR: GET and POST not supported yet.", "-", "-", {}]



        
    # create the script file to be run by K
    input_file_for_k = filename + ".phptemp"
    if ('FILE' in crnt_test):
        write_data_on_file(crnt_test["FILE"].strip(), input_file_for_k) 
    if ('FILEOF' in crnt_test):
        write_data_on_file(crnt_test["FILEOF"].strip(), input_file_for_k)         
    try:
        # name of auxiliary files to be given to K tool (one for writing config to, other is php source to run).
        temp_file = filename + ".tmp"     
        # calling KPHP here, and getting the result
        # ,"--output-file " + temp_file
        subprocess.check_call(["krun", "--parser", "java -jar parser/parser.jar" ,  ">", temp_file, input_file_for_k], shell=True)
        # BMK: with non-determinisitic input we need -c option on command line
        # -c MyDb='db(\"a\",\"b\",\"c\",\"d\")'
        #result = result.strip()
        #result_new_line = result.replace(" ", "").replace('\n', "").replace("\t ", "")
        #result_new_line = result.translate( None, string.whitespace )
    # TODO: in case the file cause parsing error, the exception is not caught anymore!!!
    except subprocess.CalledProcessError as e:
        outcome = "parsing issue"
        print ("krun error => " + outcome)
        print(e.output)
        return [outcome, "Parsing problem. Probably due to outdated parser.", "-", "-",{}]

    # and finally we parse the output from KPHP...
    try:
        konfig = parseString(get_file_content(temp_file))
        kcell = str(konfig.getElementsByTagName("k")[0].toxml()).strip("\n\t ")
        trace = str(konfig.getElementsByTagName("trace")[0].toxml())
        domain = str(konfig.getElementsByTagName("domain")[0].toxml()).replace("<domain>", "").replace("</domain>", "")
        domain = "".join(domain.split())
        outcell = str(konfig.getElementsByTagName("out")[0].toxml())
        residual = kcell.replace("<k>", "").replace("</k>", "").strip("\n\t ")
        result = outcell.replace("<out>", "").replace("</out>", "").replace("\t", "").replace(" ", "").replace("&quot;", "").replace("\\r\\n", "")
        #result=re.sub(r'.out.(.*)..out.', r'\1', outcell)
        result2=re.sub(r'ListItem\((.*?)\)\n', r'\1\n', result)
        result3=re.sub(r'#(ostream|buffer|\r)(.*?)\n', "", result2)
        result_new_line = "".join(result3.split())
        #print result3
        errorcode = int(str(konfig.getElementsByTagName("errorManagement")[0].toxml()).replace("<errorManagement>", "").replace("</errorManagement>", "").strip("\n"))
    except ExpatError :
        kcell = "UNABLE TO PARSE CONFIG, CHECK MANUALLY!"
        errorcode = 4
    # get the expected result
    # TODO: manage EXPECTREGEX properly
    if ('EXPECT' in crnt_test):
        expected_result = crnt_test['EXPECT'].strip();
    if ('EXPECTF' in crnt_test):
        expected_result = crnt_test['EXPECTF'].strip();
    if (('EXPECTTYPES' in crnt_test) and (domain=="Types")):
        expected_result = crnt_test['EXPECTTYPES'].strip();
    if (('EXPECTSIGNS' in crnt_test) and (domain=="Signs")):
        expected_result = crnt_test['EXPECTSIGNS'].strip();
    if ('EXPECTREGEX' in crnt_test):
        expected_result = crnt_test['EXPECTREGEX'].strip()	
    # create version of expected result without newlines
    expected_result_new_line = "".join(expected_result.split())
    expected_result_pattern = expected_result_new_line
    if ('EXPECTF' in crnt_test or 'EXPECTREGEX' in crnt_test):
        expected_result_pattern = fromScanfStyleToRegexp(expected_result_new_line)
        expected_result_pattern = fromScanfStyleToRegexp(expected_result_new_line)
    # Passing conditions.
    try:
        regexp_match = (re.match(expected_result_pattern, result_new_line))
    except Exception:
        regexp_match = False    

    literal_match = (result_new_line == expected_result_new_line) or (result3 == expected_result)

    if ((regexp_match or literal_match) and (residual == ".K")):
        outcome = "pass"
    
    elif (errorcode == 4):
        outcome = "parsing_issue"
        print("ExpatError")
        rule_coverage = {}
    elif (errorcode == 3):
        outcome = "not_supported"
    elif (errorcode == 1 or errorcode == 2):    # LATER: specialize this 2 classes
        outcome = "output_needs_manual_review"
        rule_coverage = {}
    else:
        outcome = "fail"
    
    print ("Expected : " + expected_result)
    print ("Actual : " + result3)
    print ("=> " + outcome)
    # coverage information
    # empty dictionary
    if (outcome != "parsing_issue"):
        rule_coverage = {}
        trace = trace.split("\n")
        # remove 1st and last elems
        trace.pop(len(trace) - 1)
        trace.pop(0)
        for trace_item in trace:    
            key = re.sub('\)', '', re.sub('ListItem\(', '', re.sub('&quot;', '', trace_item))).strip()
            if key in rule_coverage:
                rule_coverage[key] += 1
            else:
                rule_coverage[key] = 1
        #print rule_coverage
    else:
        rule_coverage = {}
    
    return [outcome, result, expected_result, kcell, rule_coverage]

# get input data
test_dir = sys.argv[1]
output_file = sys.argv[2]

# generate test results in XML format
folderReport = test_folder(test_dir)

# store the XML report for comparison with next run
if not os.path.exists(test_dir + "/regression_data"):
         os.makedirs(test_dir + "/regression_data")
try: 
    ElementTree(folderReport).write(test_dir + "/regression_data/last_passes.xml")
except UnicodeDecodeError:
    print ("NOTICE: there was an error, regression data was not written...")

#generate HTML report from XML
HTMLReport = makeHTMLReport(folderReport)
write_data_on_file(HTMLReport, output_file)
