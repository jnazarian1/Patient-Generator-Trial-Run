require 'bundler/setup'
require 'rubygems'
require 'fhir_model'
require 'pry'
require 'faker'
require 'random_data'
require 'coderay'
require 'as-duration'


def createPatient(family, given)
  patient = FHIR::Patient.new(name: [FHIR::HumanName.new(family: [family], given: [given])])
end

#This decides the gender of the patient, an attribute that is used throughout the entire script
$genderChoice = ["male","female"][rand(2)]
if $genderChoice == "male"
  mockPatient = createPatient([Faker::Name.last_name],[Random.firstname_male])
  else
    mockPatient = createPatient([Faker::Name.last_name],[Random.firstname_female])
end

#These are used at the very end of this script to fix a naming bug
mockPatientLastName = mockPatient.name[0].family
mockPatientFirstName = mockPatient.name[0].given

#identifier
def addIdentifier(newUse, newSystem, newValue, newPeriod, newAssigner)
  newIdentifier = FHIR::Identifier.new(use: newUse, system: newSystem, value: newValue, period: {start: newPeriod}, assigner: {display: newAssigner})
end

#This code just generates a mock hospital and patient ID number
sampleHospitals = ["Mayo Clinic","Mount Sinai Hospital","UCLA Medical Center","Johns Hopkins Hospital","Mass General Hospital"]
num1 = rand(9).to_s << "."
num2 = rand(999).to_s << "."
num3 = rand(99).to_s << "."
num4 = rand(9).to_s << "."
num5 = rand(999).to_s << "."
mockPatient.identifier = [addIdentifier("usual", "urn:oid:" << num1 << num2 << num3 << num4 << "01", rand(999999).to_s, Faker::Time.between(18.months.ago, 13.months.ago), sampleHospitals[rand(5)])]

#name
#The 'family' and 'given' names are generated above depending on the $genderChoice
#This code just assigns a random suffix if the patient is a male (because having a female, for example, be the third generation of the same name, is impossible)
mockPatient.name[0].use = "usual"
if $genderChoice == "male"
  mockPatient.name[0].suffix = [Faker::Name.suffix]
end

#telecom
def addTelecom(newSystem, newValue, newUse)
  newTelecom = FHIR::Contact.new(system: newSystem, value: newValue, use: newUse)
end
mockPatient.telecom = [addTelecom("phone",Faker::PhoneNumber.cell_phone,"home"), addTelecom("email",Faker::Internet.email,"work",)]

#gender
if $genderChoice == "male"
  mockPatient.gender = {"coding" => ["system" => "http://hl7.org/fhir/v3/AdministratvieGender","code" => "M", "display" => "Male"],"text" => "Male"}
else
  mockPatient.gender = {"coding" => ["system" => "http://hl7.org/fhir/v3/AdministrativeGender","code" => "F", "display" => "Female"], "text" => "Female"}
end

#birthDate
mockPatient.birthDate = Faker::Date.between(31025.days.ago, 23725.days.ago)

#deceasedBoolean
deathChance = rand(10)
#if deathChance == 7
  deceasedDateTime = Faker::Date.between(1.year.ago, Date.today)
  mockPatient.deceasedBoolean = true
  mockPatient.deceasedDateTime = deceasedDateTime
#else
#  mockPatient.deceasedBoolean = false
#end

#address
def addAddress(newLine, newCity, newState, newZip, newCountry)
  newAddress = FHIR::Address.new(line: newLine, city: newCity, state: newState, zip: newZip, country: newCountry)
end
mockPatient.address = [addAddress([Faker::Address.street_address], Faker::Address.city, Faker::Address.state, Faker::Address.zip, "USA")]

#maritalStatus
maritalChance = rand(2)
if maritalChance == 1
  mockPatient.maritalStatus = {"coding" => ["system" => "http://hl7.org/fhir/v3/MaritalStatus","code" => "U","display" => "Unmarried"]}
else
  mockPatient.maritalStatus = {"coding" => ["system" => "http://hl7.org/fhir/v3/MaritalStatus","code" => "M","display" => "Married"]}
end

#multipleBirthBoolean
#Should this be randomized?
mockPatient.multipleBirthBoolean = false

#contact
def addContact()
  if $genderChoice == "male"
    newContact = FHIR::Patient::ContactComponent.new(name: {use: "usual", family: [Faker::Name.last_name], given: [Random.firstname_female]},                                                   telecom: [{system: "phone", value: Faker::PhoneNumber.cell_phone, use: "home"}])
  else
    newContact = FHIR::Patient::ContactComponent.new(name: {use: "usual", family: [Faker::Name.last_name], given: [Random.firstname_male]},                                                   telecom: [{system: "phone", value: Faker::PhoneNumber.cell_phone, use: "home"}])
  end
end
mockPatient.contact = [addContact()]
mockPatient.active = true

#managingOrganization
mockPatient.managingOrganization = {"display" => "MedStar Health"}

#multipleBirthInteger
#photo
#animal
#communication
#careProvider
#managingOrganization
#link







#MockObservations#############################################################################################################################################
def createObservation()
  newObservation = FHIR::Observation.new()
end

#Smoking Status
#This observation may be useful in certain risk models
patientSmokingStatus = createObservation()
smokingChances = [1,1,1,1,2,2,3]
smokingChoice = smokingChances[rand(7)]
if smokingChoice == 1
  patientSmokingStatus.name = {coding: [{system: "http://snomed.info/sct", code: "77176002", display: "Smoker"}], text: "Smoking Status: Smoker"}
elsif smokingChoice == 2
  patientSmokingStatus.name = {coding: [{system: "http://snomed.info/sct", code: "266919005", display: "Never Smoked Tobacco"}], text: "Smoking Status: Never Smoked Tobacco"}
elsif smokingChoice == 3
  patientSmokingStatus.name = {coding: [{system: "http://snomed.info/sct", code: "8517006", display: "Ex-Smoker"}], text: "Smoking Status: Ex-Smoker"}
end

#Blood Pressure
#This code picks a general class (normal/pre-hypertension/hypertension) and assigns a corresponding systolic and diastolic blood pressure
#This assignment will later dictate whether or not the patient has hypertension added as a condition as well
bpPossibilities = ["Normal","Normal","Normal","Pre-Hypertension","Pre-Hypertension","Hypertension", "Hypertension"]
bpChoice = bpPossibilities[rand(7)]
patientSystolicBloodPressure = createObservation()
patientSystolicBloodPressure.name = {coding: [{system: "http://snomed.info/sct", code: "271649006", display: "Systolic Blood Pressure"}], text: " Systolic Blood Pressure"}
patientSystolicBloodPressure.valueQuantity = {}
patientDiastolicBloodPressure = createObservation()
patientDiastolicBloodPressure.name = {coding: [{system: "http://snomed.info/sct", code: "271650006", display: "Diastolic Blood Pressure"}], text: "Diastolic Blood Pressure"}
patientDiastolicBloodPressure.valueQuantity = {}
case bpChoice
when "Normal"
  patientSystolicBloodPressure.valueQuantity.value = rand(100..119)
  patientDiastolicBloodPressure.valueQuantity.value = rand(65..79)
when "Pre-Hypertension"
  patientSystolicBloodPressure.valueQuantity.value = rand(120..139)
  patientDiastolicBloodPressure.valueQuantity.value = rand(80..89)
when "Hypertension"
  patientSystolicBloodPressure.valueQuantity.value = rand(140..180)
  patientDiastolicBloodPressure.valueQuantity.value = rand(90..110)
end
patientSystolicBloodPressure.valueQuantity.units = "mmHg"
patientDiastolicBloodPressure.valueQuantity.units = "mmHg"

#Cholesterol
#This code assigns the patient LDL, HDL, and triglyceride values
#The code is formatted this way because all three are very closely related
cholesterolChance = ["Optimal","Optimal","Optimal","Near Optimal","Borderline","Borderline","High","Very High"]
cholesterolChoice = cholesterolChance[rand(8)]
patientLDL = createObservation()
patientLDL.valueQuantity = {}
patientLDL.name = {text: "LDL Cholesterol"}
patientHDL = createObservation()
patientHDL.valueQuantity = {}
patientHDL.name = {text: "HDL Cholesterol"}
patientTriglyceride = createObservation()
patientTriglyceride.name = {text: "Triglyceride Level"}
patientTriglyceride.valueQuantity = {}
case cholesterolChoice
when "Optimal"
  patientLDL.valueQuantity.value = rand(80..99)
  patientHDL.valueQuantity.value = rand(60..69)
  patientTriglyceride.valueQuantity.value = rand(100..139)
when "Near Optimal"
  patientLDL.valueQuantity.value = rand(100..129)
  patientHDL.valueQuantity.value = rand(50..59)
  patientTriglyceride.valueQuantity.value = rand(140..159)
when "Borderline"
  patientLDL.valueQuantity.value = rand(130..159)
  patientHDL.valueQuantity.value = rand(40..60)
  patientTriglyceride.valueQuantity.value = rand(160..199)
when "High"
  patientLDL.valueQuantity.value = rand(160..189)
  patientHDL.valueQuantity.value = rand(40..49)
  patientTriglyceride.valueQuantity.value = rand(200..299)
when "Very High"
  patientLDL.valueQuantity.value = rand(190..220)
  patientHDL.valueQuantity.value = rand(30..39)
  patientTriglyceride.valueQuantity.value = rand(300..399)
end
#This just assigns unts to all three values
patientHDL.valueQuantity.units = "mg/dL"
patientLDL.valueQuantity.units = "mg/dL"
patientTriglyceride.valueQuantity.units = "mg/dL"

#Age
#This code gives the patient an integer age which may be useful for some rick models which require integers
patientAge = createObservation()
patientAge.name = {text: "Age"}
patientAge.valueQuantity = {}
patientAge.valueQuantity.value = Time.now.year - mockPatient.birthDate.year
patientAge.valueQuantity.units = "years"

#Height and Weight
#This code chooses a random, relative size, and then assigns an appropriate height and weight
#Essentially this code avoids super tall and super lightweight patients, as well as super short and super heavy patients
sizePossibilities = ["Small","Medium","Large","Extra Large"]
sizeChoice = sizePossibilities[rand(4)]
patientHeight = createObservation()
patientHeight.name = {coding: [{system: "http://snomed.info/sct", code: "248327008", display: "Height"}], text: "Height"}
patientHeight.valueQuantity = {}
patientWeight = createObservation()
patientWeight.name = {coding: [{system: "http://snomed.info/sct", code: "27113001", display: "Body Weight"}], text: "Weight"}
patientWeight.valueQuantity = {}
if $genderChoice == "male"
  case sizeChoice
  when "Small"
    patientHeight.valueQuantity.value = rand(60..65)
    patientWeight.valueQuantity.value = rand(100..140)
  when "Medium"
    patientHeight.valueQuantity.value = rand(65..70)
    patientWeight.valueQuantity.value = rand(140..180)
  when "Large"
    patientHeight.valueQuantity.value = rand(70..75)
    patientWeight.valueQuantity.value = rand(180..230)
  when "Extra Large"
    patientHeight.valueQuantity.value = rand(75..80)
    patientWeight.valueQuantity.value = rand(230..300)
  end
else
  case sizeChoice
  when "Small"
    patientHeight.valueQuantity.value = rand(55..60)
    patientWeight.valueQuantity.value = rand(80..120)
  when "Medium"
    patientHeight.valueQuantity.value = rand(60..65)
    patientWeight.valueQuantity.value = rand(120..160)
  when "Large"
    patientHeight.valueQuantity.value = rand(65..70)
    patientWeight.valueQuantity.value = rand(160..200)
  when "Extra Large"
    patientHeight.valueQuantity.value = rand(70..75)
    patientWeight.valueQuantity.value = rand(200..250)
  end
end
#This is just assigning labels to the previously assigned values
patientHeight.valueQuantity.units = "inches"
patientWeight.valueQuantity.units = "pounds"

#Body Mass Index
#This calculation was found on the internet, it's just the weight kg divided by the square of the height in meters
patientBMI = createObservation()
patientBMI.name = {coding: [{system: "http://snomed.info/sct", code: "60621009", display: "Body Mass Index"}], text: "Body Mass Index"}
patientBMI.valueQuantity = {}
patientWeightInKg = patientWeight.valueQuantity.value * 0.45
patientHeightInMeters = patientHeight.valueQuantity.value * 0.025
patientHeightInMetersSquared = patientHeightInMeters ** 2
patientBMI.valueQuantity.value = (patientWeightInKg/patientHeightInMetersSquared).to_i

#Glucose Level
#This observation will dictate whether or not a patient has diabetes; it may also be useful for certain risk models
patientGlucose = createObservation()
patientGlucose.name = {coding: [{system: "http://snomed.info/sct", code: "33747003", display: "Blood Glucose Level"}], text: "Blood Glucose Level"}
patientGlucose.valueQuantity = {}
patientGlucose.valueQuantity.value = rand(100..250)
patientGlucose.valueQuantity.units = "mg/dL"

#Parental History
#This observation may be useful for certain risk models
parent1Diabetes = [true, false, false, false, false][rand(0..4)]
parent2Diabetes = [true ,false, false, false, false][rand(0..4)]
parent1Hypertension = [true, false, false, false][rand(0..3)]
parent2Hypertension = [true, false, false, false][rand(0..3)]
parent1Cancer = [true, false, false, false][rand(0..3)]
parent2Cancer = [true, false, false, false][rand(0..3)]








#MockAllergies#############################################################################################################################################
allergyChances = ["N/A", "N/A", "N/A", "N/A", "Mold", "Bees", "Latex", "Penicillin", ]
allergyChoice = allergyChances[rand(8)]
def createAllergy()
  newAllergy = FHIR::AllergyIntolerance.new(status: "generated")
end
unless allergyChoice == "N/A"
  allergyName = "Allergy to " << allergyChoice
  mockAllergy = createAllergy()
  case allergyChoice
  when allergyChoice == 5
    allergyCode = "419474003"
  when allergyChoice == 6
    allergyCode = "424213003"
  when allergyChoice == 7
    allergyCode = "300916003"
  when allergyChoice == 8
    allergyCode = "91936005"
  end
  mockAllergy.identifier[0] = {"label" => "#{allergyName}", "system" => "http://snomed.info/sct", "value" => "#{allergyCode}"}
  mockAllergy.criticality = ["mild","moderate","severe"][rand(3)]
  mockAllergy.status = "confirmed"
  mockAllergy.substance = {"display" => "#{allergyName}"}
end








#MockConditions#############################################################################################################################################

#These are just empty arrays that will keep track of the patients conditions/medications/encounters/medicationStatements
#Every time the script goes through the following 'until' loop, the information is added to these three arrays
allConditions = []
allMedications = []
allEncounters = []
allMedicationStatements = []

#This loop will give the patients one condition, the corresponding medication, and an appropriate encounter for each iteration
#The number of iterations through this loop is randomized for each patient
conditionCounter = 0
numberOfConditions = rand(7)

#This 'if' statement ensures that if the patient has high blood pressure or high glucose levels, then the patient MUST have at least 1 (or two if both are true) conditions
if bpChoice == "Hypertension"
  if numberOfConditions == 0
    numberOfConditions = numberOfConditions + 1
  end
end
if patientGlucose.valueQuantity.value > 200
  if numberOfConditions == 0
    numberOfConditions = numberOfConditions + 1
  elsif numberOfConditions == 1
    if bpChoice == "Hypertension"
      numberOfConditions = numberOfConditions + 1
    end
  end
end

until conditionCounter == numberOfConditions
  conditionCounter = conditionCounter + 1

#This code ensures that conditions will not be diagnosed after death
dateAssertedVar = Faker::Date.between(1.year.ago, Date.today)
while dateAssertedVar.to_s > mockPatient.deceasedDateTime.to_s
  dateAssertedVar = Faker::Date.between(1.year.ago, Date.today)
end


def createCondition()
  newCondition = FHIR::Condition.new(status: "generated")
end

#This is an array of hashes, each hash being a possible condition
#An index is then chosen randomly, therefore randomizing the conditions given to each patient
#If medication_id == 0, then there is no medication for that condition
conditionRepository = [
  {condition_id: 1, icd9code: "290.0", display: "Dementia",                         medication_id: 1,  overnights: "0",     abatementPossible: "false"},
  {condition_id: 2, icd9code: "482.9", display: "Bacterial Pneumonia",              medication_id: 2,  overnights: "4-6",   abatementPossible: "true", recoveryEstimate: "week"},
  {condition_id: 3, icd9code: "428.0", display: "Congestive Heart Failure",         medication_id: 3,  overnights: "5-7",   abatementPossible: "sometimes", recoveryEstimate: "sixMonths"},
  {condition_id: 4, icd9code: "250.00", display: "Diabetes",                        medication_id: 4,  overnights: "1-2",   abatementPossible: "false"},
  {condition_id: 5, icd9code: "365.72", display: "Glaucoma",                        medication_id: 5,  overnights: "0",     abatementPossible: "false"},
  {condition_id: 6, icd9code: "711.90", display: "Arthritis",                       medication_id: 6,  overnights: "0",     abatementPossible: "false"},
  {condition_id: 7, icd9code: "487.8", display: "Influenza",                        medication_id: 7,  overnights: "3-4",   abatementPossible: "true", recoveryEstimate: "week"},
  {condition_id: 8, icd9code: "401.9", display: "Hypertension",                     medication_id: 8,  overnights: "0",     abatementPossible: "sometimes", recoveryEstimate: "sixMonths"},
  {condition_id: 9, icd9code: "733.01", display: "Osteoporosis",                    medication_id: 9,  overnights: "0",     abatementPossible: "false"},
  {condition_id: 10, icd9code: "466.0", display: "Bronchitis",                      medication_id: 18, overnights: "4-6",   abatementPossible: "true", recoveryEstimate: "week"},
  {condition_id: 11, icd9code: "389.9", display: "Hearing Loss",                    medication_id: 0,  overnights: "0",     abatementPossible: "false"},
  {condition_id: 12, icd9code: "535.00", display: "Gastritis",                      medication_id: 12, overnights: "3-4",   abatementPossible: "true", recoveryEstimate: "week"},
  {condition_id: 13, icd9code: "244.9", display: "Hypothyroidism",                  medication_id: 13, overnights: "0",     abatementPossible: "true", recoveryEstimate: "sixMonths"},
  {condition_id: 14, icd9code: "285.9", display: "Anemia",                          medication_id: 14, overnights: "4-5",   abatementPossible: "true", recoveryEstimate: "sixMonths"},
  {condition_id: 15, icd9code: "492.8", display: "Emphysema",                       medication_id: 15, overnights: "3-5",   abatementPossible: "false"},
  {condition_id: 16, icd9code: "533.30", display: "Peptic Ulcer",                   medication_id: 16, overnights: "6-7",   abatementPossible: "true", recoveryEstimate: "threeMonths"},
  {condition_id: 17, icd9code: "554.1", display: "Varicose Veins",                  medication_id: 17, overnights: "5-7",   abatementPossible: "false"},
  {condition_id: 18, icd9code: "362.50", display: "Macular Degeneration",           medication_id: 10, overnights: "0",     abatementPossible: "false"},
  {condition_id: 19, icd9code: "274.9", display: "Gout",                            medication_id: 19, overnights: "4-6",   abatementPossible: "true", recoveryEstimate: "sixMonths"},
  {condition_id: 20, icd9code: "564.00", display: "Constipation",                   medication_id: 20, overnights: "0",     abatementPossible: "true", recoveryEstimate: "week"},
  {condition_id: 21, icd9code: "440.9", display: "Athersclerosis",                  medication_id: 8,  overnights: "3-5",   abatementPossible: "false"},
  {condition_id: 22, icd9code: "416.9", display: "Pulmonary Heart Disease",         medication_id: 8,  overnights: "5-7",   abatementPossible: "sometimes", recoveryEstimate: "sixMonths"},
  {condition_id: 23, icd9code: "530.81", display: "Esophageal Reflux",              medication_id: 16, overnights: "0",     abatementPossible: "true", recoveryEstimate: "threeMonths"},
  {condition_id: 24, icd9code: "003.9", display: "Salmonella",                      medication_id: 21, overnights: "3-5",   abatementPossible: "true", recoveryEstimate: "week"},
  {condition_id: 25, icd9code: "011.90", display: "Pulmonary Tuberculosis",         medication_id: 22, overnights: "15-20", abatementPossible: "true", recoveryEstimate: "sixMonths"},
  {condition_id: 26, icd9code: "265.0", display: "Beriberi",                        medication_id: 23, overnights: "0",     abatementPossible: "true", recoveryEstimate: "threeMonths"},
  {condition_id: 27, icd9code: "377.75", display: "Cortical Blindness",             medication_id: 0,  overnights: "1-3",   abatementPossible: "false"},
  {condition_id: 28, icd9code: "733.20", display: "Bone Cyst",                      medication_id: 0,  overnights: "4-6",   abatementPossible: "true", recoveryEstimate: "sixMonths"},
  {condition_id: 28, icd9code: "814.00", display: "Carpal Bone Fracture",           medication_id: 0,  overnights: "0-1",   abatementPossible: "true", recoveryEstimate: "threeMonths"},
  {condition_id: 29, icd9code: "825.20", display: "Foot Fracture",                  medication_id: 0,  overnights: "0-1",   abatementPossible: "true", recoveryEstimate: "threeMonths"},
  {condition_id: 30, icd9code: "873.63", display: "Broken Tooth",                   medication_id: 0,  overnights: "0-1",   abatementPossible: "true", recoveryEstimate: "week"},
  {condition_id: 31, icd9code: "541", display: "Appendicitis",                      medication_id: 0,  overnights: "3-4",   abatementPossible: "true", recoveryEstimate: "week"},
  {condition_id: 32, icd9code: "943.01", display: "Forearm Burn",                   medication_id: 0,  overnights: "0-2",   abatementPossible: "true", recoveryEstimate: "week"},
  {condition_id: 33, icd9code: "945.06", display: "Thigh Burn",                     medication_id: 0,  overnights: "2-4",   abatementPossible: "true", recoveryEstimate: "week"},
  {condition_id: 34, icd9code: "004.2", display: "Shigella",                        medication_id: 0,  overnights: "4-5",   abatementPossible: "true", recoveryEstimate: "week"},
  {condition_id: 35, icd9code: "023.9", display: "Brucellosis",                     medication_id: 24, overnights: "10-15", abatementPossible: "true", recoveryEstimate: "sixMonths"},
  {condition_id: 36, icd9code: "033.0", display: "Whooping Cough (B. Pertussis)",   medication_id: 25, overnights: "3-4",   abatementPossible: "true", recoveryEstimate: "week"},
  {condition_id: 37, icd9code: "081.9", display: "Typhus",                          medication_id: 2,  overnights: "3-9",   abatementPossible: "true", recoveryEstimate: "threeMonths"},
  {condition_id: 38, icd9code: "072.9", display: "Mumps",                           medication_id: 0,  overnights: "3-5",   abatementPossible: "true", recoveryEstimate: "week"},
  {condition_id: 39, icd9code: "272.4", display: "Hyperlipidemia",                  medication_id: 11, overnights: "0",     abatementPossible: "true", recoveryEstimate: "sixMonths"},
  {condition_id: 40, icd9code: "781.1", display: "Disturbances of Smell and Taste", medication_id: 11, overnights: "0",     abatementPossible: "true", recoveryEstimate: "sixMonths"}
]

#This code creates a condition then chooses a random index that dictates which condition in the repository is assigned
mockCondition = createCondition()
mockCondition.subject = {reference: "mockPatient/",
                         display: mockPatient.name[0].given.to_s[3...mockPatient.name[0].given.to_s.length-3] << " " << mockPatient.name[0].family.to_s[3...mockPatient.name[0].family.to_s.length-3]}

#This if else makes it so the patients are more likely to have the top ten most common geriatric diseases (but it is still possible for them to have any condition in the conditionRepository)
conditionChoice = rand(2)
if conditionChoice == 1
  conditionIndex = rand(conditionRepository.count) - 1
else
  conditionIndex = rand(0..9)
end

#This 'if/else' statement ensures that patients have the Diabetes condition if and only if they have high blood glucose levels (decided in observations)
if patientGlucose.valueQuantity.value > 200
  unless allConditions.include? ("Diabetes")
    conditionIndex = 3
  end
else
  while conditionIndex == 3
    conditionIndex = rand(conditionRepository.count) - 1
  end
end

#This 'if/else' statement ensures that patients have the Hypertension condition if and only if they have high blood pressure (decided in observations)
if bpChoice == "Hypertension"
  unless allConditions.include? ("Hypertension")
    conditionIndex = 7
  end
else
  while conditionIndex == 7
    conditionIndex = rand(conditionRepository.count) - 1
  end
end

#This code iterates through the allConditions array and chooses a new conditionIndex if the patient already had that condition
#Essentially it prevents duplicate conditions
allConditions.each do |condition|
  if condition.code.coding[0].code == conditionRepository[conditionIndex][:icd9code]
    conditionIndex = rand(conditionRepository.count) - 1
  end
end

#This code essentially takes the information from the indexed condition in the repository and translates it to FHIR format
conditionDisplayVar = conditionRepository[conditionIndex][:display]
conditionCodeVar = conditionRepository[conditionIndex][:icd9code]
mockCondition.code = {coding: [{system: "http://hl7.org/fhir/sid/icd-9", code: conditionCodeVar, display: conditionDisplayVar}], text: conditionDisplayVar}
mockCondition.category = {coding: [{system: "http://hl7.org/fhir/condition-category", code: "diagnosis", display: "Diagnosis"}]}
mockCondition.status = "confirmed"
abatementPossibleVar = conditionRepository[conditionIndex][:abatementPossible]
recoveryEstimateVar = conditionRepository[conditionIndex][:recoveryEstimate]

#This block of code determines the asserted and abatement dates of the condition
dateAssertedVar = Faker::Date.between(1.year.ago, 1.day.ago)
mockCondition.dateAsserted = dateAssertedVar
#Is onset date important?
if abatementPossibleVar == "true"
  abatementChoice = 1
elsif abatementPossibleVar == "sometimes"
  abatementChoice = rand(2)
else
  abatementChoice = 2
end
if abatementChoice == 1
  mockCondition.abatementBoolean = true
  if recoveryEstimateVar == "sixMonths"
    abatementDateVar = dateAssertedVar + rand(5..7).months + rand(0..20).days
  elsif recoveryEstimateVar == "threeMonths"
    abatementDateVar = dateAssertedVar + rand(2..3).months + rand(0..20).days
  elsif recoveryEstimateVar == "week"
    abatementDateVar = dateAssertedVar + rand(6..10).days
  else
    return "Error: Recovery Estimate for this condition is not supported"
  end
else
  mockCondition.abatementBoolean = false
end
if abatementDateVar.to_s > Date.today.to_s
  mockCondition.abatementBoolean = false
else
  mockCondition.abatementBoolean = true
  mockCondition.abatementDate = abatementDateVar
end







#MockEncounters#############################################################################################################################################
def createEncounter()
  newEncounter = FHIR::Encounter.new()
end

#This code chooses a random period for the hospital stay within the range specific to each condition
lowStayPeriod = conditionRepository[conditionIndex][:overnights].split("-").first.to_i
highStayPeriod = conditionRepository[conditionIndex][:overnights].split("-").second.to_i
stayPeriod = rand(lowStayPeriod..highStayPeriod).days + rand(6).hours + rand(60).minutes + rand(60).seconds

#This code creates an encounter that corresponds with the previously assigned condition and the date that it was asserted
mockEncounter = createEncounter()
if conditionRepository[conditionIndex][:overnights] == "0"
  mockEncounter.identifier = [{"use" => "usual", "label" => mockPatient.name[0].given[0][0] << "'s visit on " << dateAssertedVar.to_s}]
else
  mockEncounter.identifier = [{"use" => "usual", "label" => mockPatient.name[0].given[0][0] << "'s overnight visit from " << dateAssertedVar.to_s << " to " << (dateAssertedVar + stayPeriod).to_s}]
end


mockEncounter.status = "finished"
mockEncounter.subject = {"display" => mockPatient.name[0].given[0][0] << " " << mockPatient.name[0].family[0][0]}
if conditionRepository[conditionIndex][:overnights] == "0"
  mockEncounter.period = {"start" => dateAssertedVar, "end" => dateAssertedVar + rand(6).hours + rand(60).minutes + rand(60).seconds}
else
  #This code takes the string value from the :overnights key in the conditionRepository and translates it to create a period for the encounter
  lowStayPeriod = conditionRepository[conditionIndex][:overnights].split("-").first.to_i
  highStayPeriod = conditionRepository[conditionIndex][:overnights].split("-").second.to_i
  stayPeriod = rand(lowStayPeriod..highStayPeriod)
  mockEncounter.period = {"start" => dateAssertedVar, "end" => dateAssertedVar + stayPeriod}
end
mockEncounter.serviceProvider = {"display" => "Medstar Health"}

#This code randomizes readmission, but at this stage it is only a boolean
#Should this be more logically randomized?
reAdmissionPossible = rand(5)
if reAdmissionPossible == 1
  mockEncounter.hospitalization = {"reAdmission" => true}
else
  mockEncounter.hospitalization = {"reAdmission" => false}
end


if conditionRepository[conditionIndex][:overnights] == "0"
  #This 'if' statement just determines whether to use 'he' or 'she' in the mock.Encounter.text
  if $genderChoice == "male"
    mockEncounter.reason = {"text" => "#{mockPatient.name[0].given[0][0]} #{mockPatient.name[0].family[0][0]} came in for a non-overnight visit where he was diagnosed with #{mockCondition.code.text}."}
  else
    mockEncounter.reason = {"text" => "#{mockPatient.name[0].given[0][0]} #{mockPatient.name[0].family[0][0]} came in for a non-overnight visit where she was diagnosed with #{mockCondition.code.text}."}
  end
else
  #This 'if' statement just determines whether to use 'he' or 'she' in the mock.Encounter.text
  if $genderChoice == "male"
    mockEncounter.reason = {"text" => "#{mockPatient.name[0].given[0][0]} #{mockPatient.name[0].family[0][0]} stayed for #{stayPeriod} nights after being diagnosed with #{mockCondition.code.text}."}
  else
    mockEncounter.reason = {"text" => "#{mockPatient.name[0].given[0][0]} #{mockPatient.name[0].family[0][0]} stayed for a #{stayPeriod} nights after being diagnosed with #{mockCondition.code.text}."}
  end
end








#MockMedications#############################################################################################################################################
def createMedication()
  newMedication = FHIR::Medication.new()
end

#This is the repository of medications; as of now the indices correspond with those of their corresponding diseases
#If the medication is taken as needed, the rate is the maximum suggested dosage
#The rate symbol has seemingly unecessary spaces, but they are needed for cutting the string into pieces for the MedicationStatement
medicationRepository = [
  {medication_id: 1, rxNormCode: "997224", brandName: "Aricept",                       brand?: true, "tradeName" => "Donepezil Hydrochloride 10mg Oral Tablet",                              asNeeded: false, rate: "10 mg / day"},
  {medication_id: 2, rxNormCode: "141962", brandName: "N/A",                           brand?: false, "tradeName" => "Azithromycin 250mg Oral Capsule",                                      asNeeded: false, rate: "500 mg / day"},
  {medication_id: 3, rxNormCode: "104376", brandName: "Zestril",                       brand?: true, "tradeName" => "Lisinopril 5mg Oral Tablet",                                            asNeeded: false, rate: "5 mg / day"},
  {medication_id: 4, rxNormCode: "860998", brandName: "Fortamet",                      brand?: true, "tradeName" => "Metformin Hydrochloride 1000mg Extended Release Oral Tablet",           asNeeded: false, rate: "1000 mg / day"},
  {medication_id: 5, rxNormCode: "1186297", brandName: "XALATAN Ophthalmic Solution",  brand?: true, "tradeName" => "N/A",                                                                   asNeeded: false, rate: "1 drop / day"},
  {medication_id: 6, rxNormCode: "369070", brandName: "Tylenol",                       brand?: true, "tradeName" => "Acetaminophen 650mg Tablet",                                            asNeeded: true, rate: "3900 mg / day"},
  {medication_id: 7, rxNormCode: "261315", brandName: "TamilFlu",                      brand?: true, "tradeName" => "Oseltamivir 75mg Oral Tablet",                                          asNeeded: false, rate: "150 mg / day"},
  {medication_id: 8, rxNormCode: "104377", brandName: "Zestril",                       brand?: true, "tradeName" => "Lisinopril 10mg Oral Tablet",                                           asNeeded: false, rate: "10 mg / day"},
  {medication_id: 9, rxNormCode: "904421", brandName: "Fosamax",                       brand?: true, "tradeName" => "Alendronate 10mg Oral Tablet",                                          asNeeded: false, rate: "10 mg / day"},
  {medication_id: 10, rxNormCode: "644300", brandName: "Lucentis",                     brand?: true, "tradeName" => "Ranibizumab Injectable Solution",                                       asNeeded: false, rate: "0.5 mg / month"},
  {medication_id: 11, rxNormCode: "617310", brandName: "N/A",                          brand?: false, "tradeName" => "Atorvastatin 20mg Oral Tablet",                                        asNeeded: false, rate: "20 mg / day"},
  {medication_id: 12, rxNormCode: "197517", brandName: "N/A",                          brand?: false, "tradeName" => "Clarithromycin 500mg Oral Tablet",                                     asNeeded: false, rate: "500 mg / day"},
  {medication_id: 13, rxNormCode: "966180", brandName: "Levothroid",                   brand?: true, "tradeName" => "Levothyroxine Sodium 0.1mg Oral Tablet",                                asNeeded: false, rate: "0.1 mg / day"},
  {medication_id: 14, rxNormCode: "849612", brandName: "Bifera",                       brand?: true, "tradeName" => "FE HEME Polypeptide 6mg/Polysaccharide Iron Complex 22 MG Oral Tablet", asNeeded: false, rate: "6 mg / day"},
  {medication_id: 15, rxNormCode: "198145", brandName: "N/A",                          brand?: false, "tradeName" => "Prednisone 10mg Oral Tablet",                                          asNeeded: false, rate: "10 mg / day"},
  {medication_id: 16, rxNormCode: "902622", brandName: "Dexilant",                     brand?: true, "tradeName" => "Dexlansoprazole 30mg",                                                  asNeeded: false, rate: "30 mg / day"},
  {medication_id: 17, rxNormCode: "968177", brandName: "Asclera",                      brand?: true, "tradeName" => "Polidocanol 5mg/mL",                                                    asNeeded: false, rate: "10 mL / week"},
  {medication_id: 18, rxNormCode: "203948", brandName: "Amoxil",                       brand?: true, "tradeName" => "Amoxicillin 250mg Oral Capsule",                                        asNeeded: false, rate: "1000 mg / day"},
  {medication_id: 19, rxNormCode: "197540", brandName: "N/A",                          brand?: false, "tradeName" => "Colchicine 0.5mg Oral Tablet",                                         asNeeded: false, rate: "0.5 mg / day"},
  {medication_id: 20, rxNormCode: "1247761", brandName: "Colace",                      brand?: true, "tradeName" => "Docusate Sodium 50mg Oral Capsule",                                     asNeeded: true, rate: "300 mg / day"},
  {medication_id: 21, rxNormCode: "978013", brandName: "Imodium",                      brand?: true, "tradeName" => "Loperamide Hydrochloride 2mg Oral Capsule",                             asNeeded: true, rate: "16 mg / day"},
  {medication_id: 22, rxNormCode: "197832", brandName: "N/A",                          brand?: false, "tradeName" => "Isoniazid 300mg Oral Tablet",                                          asNeeded: false, rate: "300 mg / day"},
  {medication_id: 23, rxNormCode: "316812", brandName: "N/A",                          brand?: false, "tradeName" => "Thiamine 50mg",                                                        asNeeded: false, rate: "50 mg / day"},
  {medication_id: 24, rxNormCode: "562918", brandName: "Sumycin",                      brand?: true, "tradeName" => "Tetracycline 500mg",                                                    asNeeded: false, rate: "500 mg / day"},
  {medication_id: 25, rxNormCode: "317364", brandName: "N/A",                          brand?: false, "tradeName" => "Erythromycin 250mg",                                                   asNeeded: false, rate: "250 mg / day"},
  {medication_id: 26, rxNormCode: "884319", brandName: "Zosyn",                        brand?: true, "tradeName" => "Piperacillin Injectable Solution",                                      asNeeded: false, rate: "15 g / day"}

]

#This 'unless' statement is for conditions that don't have medications (in which case the loop will omit the medication and MedicationStatement sections)
unless conditionRepository[conditionIndex][:medication_id] == 0
  #This code creates a medication and then takes the information from the medication repository that corresponds to the previously created disease
  mockMedication = createMedication()
  mockMedication.isBrand = medicationRepository[conditionRepository[conditionIndex][:medication_id]-1][:brand?]
  mockMedication.kind = "Product"

  if mockMedication.isBrand == true
    mockMedication.name = medicationRepository[conditionRepository[conditionIndex][:medication_id]-1][:brandName]
    mockMedication.code = {coding: [{system: "http://www.nlm.nih.gov/research/umls/rxnorm/", code: medicationRepository[conditionRepository[conditionIndex][:medication_id]-1][:rxNormCode], display: medicationRepository[conditionRepository[conditionIndex][:medication_id]-1][:brandName] << " " << "(Trade Name: " << medicationRepository[conditionRepository[conditionIndex][:medication_id]-1]["tradeName"] << ")"}]}
    #The following line was causing a bug in the line above so I took it out for the time being as :text is not terrible important
    #text: medicationRepository[conditionRepository[conditionIndex][:medication_id]-1][:brandName] << " " << "(Trade Name: " << medicationRepository[conditionRepository[conditionIndex][:medication_id]-1]["tradeName"] << ")"}]}
  elsif medicationRepository[conditionRepository[conditionIndex][:medication_id]]["tradeName"] == "N/A"
    mockMedication.name = medicationRepository[conditionRepository[conditionIndex][:medication_id]-1][:brandName]
    mockMedication.code = {coding: [{system: "http://www.nlm.nih.gov/research/umls/rxnorm/", code: medicationRepository[conditionRepository[conditionIndex][:medication_id-1]][:rxNormCode], display: medicationRepository[conditionRepository[conditionIndex][:medication_id]-1][:brandName]}], text: medicationRepository[conditionRepository[conditionIndex][:medication_id]-1][:brandName].to_s}
  else
    mockMedication.name = medicationRepository[conditionRepository[conditionIndex][:medication_id]-1]["tradeName"]
    mockMedication.code = {coding: [{system: "http://www.nlm.nih.gov/research/umls/rxnorm/", code: medicationRepository[conditionRepository[conditionIndex][:medication_id]-1][:rxNormCode], display: medicationRepository[conditionRepository[conditionIndex][:medication_id]-1][:brandName]}], text: medicationRepository[conditionRepository[conditionIndex][:medication_id]-1][:brandName].to_s}
  end

  #These variables are used in the Medication Statement section
  mockMedicationNameVar = medicationRepository[conditionRepository[conditionIndex][:medication_id]-1][:brandName]
  mockMedicationAsNeededVar = medicationRepository[conditionRepository[conditionIndex][:medication_id]-1][:asNeeded]
  mockMedicationRateVar = medicationRepository[conditionRepository[conditionIndex][:medication_id]-1][:rate]









#MedicationStatment########################################################################################################################################
def createMedicationStatement()
  newMedicationStatement = FHIR::MedicationStatement.new()
end

#This code creates a medication statement that summarizes all of the assigned medications and whether or not the prescriptions are still active
mockMedicationStatement = createMedicationStatement()
mockMedicationStatement.wasNotGiven = false
#If the condition for which the medication was given is still active, the medication statement does not have an end date
if mockCondition.abatementBoolean == true
  mockMedicationStatement.whenGiven = {"start" => dateAssertedVar, "end" => mockCondition.abatementDate}
else
  mockMedicationStatement.whenGiven = {"start" => dateAssertedVar}
end
mockMedicationStatement.medication = {"display" => "#{mockMedicationNameVar}"}
#COME BACK HERE and include reference
mockMedicationStatement.dosage = [{asNeededBoolean: mockMedicationAsNeededVar, rate: {numerator: {value: mockMedicationRateVar.split(" ").first.to_f, units: mockMedicationRateVar.split(" ").second}, denominator: {value: 1, units: mockMedicationRateVar.split(" ").last}}}]

#The following 'end' closes the 'unless' statement that omits medications and medicationStatements when the condition has no medication
end






#This 'if' statement sets the condition and corresponding medcation that were created in this loop to a numbered variable name and
#then pushes each to two separate,respective arrays: allConditions and allMedications
if conditionCounter == 1
  mockCondition1 = createCondition()
  mockCondition1 = mockCondition
  allConditions.push(mockCondition1)
  mockEncounter1 = createEncounter()
  mockEncounter1 = mockEncounter
  allEncounters << mockEncounter1
  unless conditionRepository[conditionIndex][:medication_id] == 0
  mockMedication1 = createMedication()
  mockMedication1 = mockMedication
  allMedications << mockMedication1
  mockMedicationStatement1 = createMedicationStatement()
  mockMedicationStatement1 = mockMedicationStatement
  allMedicationStatements << mockMedicationStatement1
  end
elsif conditionCounter == 2
  mockCondition2 = createCondition()
  mockCondition2 = mockCondition
  allConditions.push(mockCondition2)
  mockEncounter2 = createEncounter()
  mockEncounter2 = mockEncounter
  allEncounters << mockEncounter2
  unless conditionRepository[conditionIndex][:medication_id] == 0
  mockMedication2 = createMedication()
  mockMedication2 = mockMedication
  allMedications << mockMedication2
  mockMedicationStatement2 = createMedicationStatement()
  mockMedicationStatement2 = mockMedicationStatement
  allMedicationStatements << mockMedicationStatement2
  end
elsif conditionCounter == 3
  mockCondition3 = createCondition()
  mockCondition3 = mockCondition
  allConditions.push(mockCondition3)
  mockEncounter3 = createEncounter()
  mockEncounter3 = mockEncounter
  allEncounters << mockEncounter3
  unless conditionRepository[conditionIndex][:medication_id] == 0
  mockMedication3 = createMedication()
  mockMedication3 = mockMedication
  allMedications << mockMedication3
  mockMedicationStatement3 = createMedicationStatement()
  mockMedicationStatement3 = mockMedicationStatement
  allMedicationStatements << mockMedicationStatement3
  end
elsif conditionCounter == 4
  mockCondition4 = createCondition()
  mockCondition4 = mockCondition
  allConditions.push(mockCondition4)
  mockEncounter4 = createEncounter()
  mockEncounter4 = mockEncounter
  allEncounters << mockEncounter4
  unless conditionRepository[conditionIndex][:medication_id] == 0
  mockMedication4 = createMedication()
  mockMedication4 = mockMedication
  allMedications << mockMedication4
  mockMedicationStatement4 = createMedicationStatement()
  mockMedicationStatement4 = mockMedicationStatement
  allMedicationStatements << mockMedicationStatement4
  end
elsif conditionCounter == 5
  mockCondition5 = createCondition()
  mockCondition5 = mockCondition
  allConditions.push(mockCondition5)
  mockEncounter5 = createEncounter()
  mockEncounter5 = mockEncounter
  allEncounters << mockEncounter5
  unless conditionRepository[conditionIndex][:medication_id] == 0
  mockMedication5 = createMedication()
  mockMedication5 = mockMedication
  allMedications << mockMedication5
  mockMedicationStatement5 = createMedicationStatement()
  mockMedicationStatement5 = mockMedicationStatement
  allMedicationStatements << mockMedicationStatement5
  end
elsif conditionCounter == 6
  mockCondition6 = createCondition()
  mockCondition6 = mockCondition
  allConditions.push(mockCondition6)
  mockEncounter6 = createEncounter()
  mockEncounter6 = mockEncounter
  allEncounters << mockEncounter6
  unless conditionRepository[conditionIndex][:medication_id] == 0
  mockMedication6 = createMedication()
  mockMedication6 = mockMedication
  allMedications << mockMedication6
  mockMedicationStatement6 = createMedicationStatement()
  mockMedicationStatement6 = mockMedicationStatement
  allMedicationStatements << mockMedicationStatement6
  end
elsif conditionCounter == 7
  mockCondition7 = createCondition()
  mockCondition7 = mockCondition
  allConditions.push(mockCondition7)
  mockEncounter7 = createEncounter()
  mockEncounter7 = mockEncounter
  allEncounters << mockEncounter7
  unless conditionRepository[conditionIndex][:medication_id] == 0
  mockMedication7 = createMedication()
  mockMedication7 = mockMedication
  allMedications << mockMedication7
  mockMedicationStatement7 = createMedicationStatement()
  mockMedicationStatement7 = mockMedicationStatement
  allMedicationStatements << mockMedicationStatement7
  end
elsif conditionCounter == 8
  mockCondition8 = createCondition()
  mockCondition8 = mockCondition
  allConditions.push(mockCondition8)
  mockEncounter8 = createEncounter()
  mockEncounter8 = mockEncounter
  allEncounters << mockEncounter8
  unless conditionRepository[conditionIndex][:medication_id] == 0
  mockMedication8 = createMedication()
  mockMedication8 = mockMedication
  allMedications << mockMedication8
  mockMedicationStatement8 = createMedicationStatement()
  mockMedicationStatement8 = mockMedicationStatement
  allMedicationStatements << mockMedicationStatement8
  end
elsif conditionCounter == 9
  mockCondition9 = createCondition()
  mockCondition9 = mockCondition
  allConditions.push(mockCondition9)
  mockEncounter9 = createEncounter()
  mockEncounter9 = mockEncounter
  allEncounters << mockEncounter9
  unless conditionRepository[conditionIndex][:medication_id] == 0
  mockMedication9 = createMedication()
  mockMedication9 = mockMedication
  allMedications << mockMedication9
  mockMedicationStatement9 = createMedicationStatement()
  mockMedicationStatement9 = mockMedicationStatement
  allMedicationStatements << mockMedicationStatement9
  end
elsif conditionCounter == 10
  mockCondition10 = createCondition()
  mockCondition10 = mockCondition
  allConditions.push(mockCondition10)
  mockEncounter10 = createEncounter()
  mockEncounter10 = mockEncounter
  allEncounters << mockEncounter10
  unless conditionRepository[conditionIndex][:medication_id] == 0
  mockMedication10 = createMedication()
  mockMedication10 = mockMedication
  allMedications << mockMedication10
  mockMedicationStatement10 = createMedicationStatement()
  mockMedicationStatement10 = mockMedicationStatement
  allMedicationStatements << mockMedicationStatement10
  end
end

#Below is the end of the 'until' loop that creates the conditions and their corresponding medications amedication statements
end

#Somewhere in the 'until' loop, the patient's name gets messed up. The following hack is to fix it
mockPatient.name[0].family[0] = mockPatientLastName[0][0].split("'").first
mockPatient.name[0].given[0] = mockPatientFirstName[0][0].split("'").first





binding.pry

puts mockPatient.to_fhir_json
