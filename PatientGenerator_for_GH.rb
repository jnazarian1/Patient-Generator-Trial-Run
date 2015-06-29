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

#managingOrganization
mockPatient.managingOrganization = {"display" => "MedStar Health"}

#This line is just to initalize the patient, it may change later
mockPatient.deceasedBoolean = false

#multipleBirthInteger
#photo
#animal
#communication
#careProvider
#managingOrganization
#link







#MockObservations#######################################################################################################################################################################################################################################################################################################
########################################################################################################################################################################################################################################################################################################################
def createObservation()
  newObservation = FHIR::Observation.new()
end

#Parental History
#This observation may be useful for certain risk models
parent1Diabetes = [true, false, false, false, false][rand(0..4)]
parent2Diabetes = [true ,false, false, false, false][rand(0..4)]
parent1Hypertension = [true, false, false, false][rand(0..3)]
parent2Hypertension = [true, false, false, false][rand(0..3)]
parent1Cancer = [true, false, false, false][rand(0..3)]
parent2Cancer = [true, false, false, false][rand(0..3)]


#Smoking Status
#This observation may be useful in certain risk models
patientSmokingStatus = createObservation()
smokingChances = [1,1,2,2,2,3]
smokingChoice = smokingChances[rand(6)]
if smokingChoice == 1
  patientSmokingStatus.name = {coding: [{system: "http://snomed.info/sct", code: "77176002", display: "Smoker"}], text: "Smoking Status: Smoker"}
elsif smokingChoice == 2
  patientSmokingStatus.name = {coding: [{system: "http://snomed.info/sct", code: "266919005", display: "Never Smoked Tobacco"}], text: "Smoking Status: Never Smoked Tobacco"}
elsif smokingChoice == 3
  patientSmokingStatus.name = {coding: [{system: "http://snomed.info/sct", code: "8517006", display: "Ex-Smoker"}], text: "Smoking Status: Ex-Smoker"}
end

#Drinking Status
#This observation may be useful in certain risk models
patientDrinkingStatus = createObservation()
drinkingChances = [1,1,1,1,2,3]
drinkingChoice = drinkingChances[rand(6)]
if drinkingChoice == 1
  patientDrinkingStatus.name = {coding: [{system: "http://snomed.info/sct", code: "228276006", display: "Drinks Casually/Occasionally"}], text: "Drinking Status: Drinks Casually/Occasionally"}
elsif drinkingChoice == 2
  patientDrinkingStatus.name = {coding: [{system: "http://snomed.info/sct", code: "86933000", display: "Heavy Drinker"}], text: "Drinking Status: Heavy Drinker"}
elsif drinkingChoice == 3
  patientDrinkingStatus.name = {coding: [{system: "http://snomed.info/sct", code: "105543003", display: "Non-Drinker"}], text: "Drinking Status: Non-Drinker"}
end

#Blood Pressure
#This code picks a general class (normal/pre-hypertension/hypertension) and assigns a corresponding systolic and diastolic blood pressure
#This assignment will later dictate whether or not the patient has hypertension added as a condition as well
if parent1Hypertension == true and parent2Hypertension == true
  bpPossibilities = ["Normal","Pre-Hypertension","Pre-Hypertension","Pre-Hypertension","Hypertension","Hypertension", "Hypertension"]
else
  bpPossibilities = ["Normal","Normal","Normal","Pre-Hypertension","Pre-Hypertension","Hypertension", "Hypertension"]
end
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
if parent1Diabetes == true && parent2Diabetes == true
  patientGlucose.valueQuantity.value = rand(180..250)
else
  patientGlucose.valueQuantity.value = rand(10..230)
end
patientGlucose.valueQuantity.units = "mg/dL"











#MockAllergies#########################################################################################################################################################################################################################################################################################################
#######################################################################################################################################################################################################################################################################################################################
allergyChances = ["N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "Mold", "Bees", "Latex", "Penicillin", ]
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








#MockConditions#########################################################################################################################################################################################################################################################################################################
########################################################################################################################################################################################################################################################################################################################

#These are just empty arrays that will keep track of the patients conditions/medications/encounters/medicationStatements
#Every time the script goes through the following 'until' loop, the information is added to these three arrays
allConditions = []
allMedications = []
allMedicationStatements = []
allEncounters = []
allProcedures = []

#This loop will give the patients one condition, the corresponding medication, and an appropriate encounter for each iteration
#The number of iterations through this loop is randomized for each patient
conditionCounter = 0
numberOfConditionPossibilities = [0,1,1,2,2,2,2,3,3,3,3,3,3,4,4,4,5,5,6,7]
numberOfConditions = numberOfConditionPossibilities[rand(numberOfConditionPossibilities.count)-1]

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

#This just specifies that the patient has not died if he/she does not have any conditions (because death is otherwise specified in the condition loop)
if conditionCounter == 0
  mockPatient.deceasedBoolean == false
end

until conditionCounter == numberOfConditions
  conditionCounter = conditionCounter + 1

def createCondition()
  newCondition = FHIR::Condition.new(status: "generated")
end

#This is an array of hashes, each hash being a possible condition
#An index is then chosen randomly, therefore randomizing the conditions given to each patient
#If medication_id == 0, then there is no medication for that condition
#mortalityChance is out of 100 of dying from that disease after being diagnosed
conditionRepository = [
  {condition_id: 1, icd9code: "401.9",   display: "Hypertension",                    medication_id: 8,  overnights: "0",     abatementChance: 40,  mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "sixMonths",   procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                }, #You can't die from hypertension, you die fromthe conditions hypertension causes
  {condition_id: 2, icd9code: "250.00",  display: "Diabetes",                        medication_id: 4,  overnights: "1-2",   abatementChance: 0,   mortalityChance: 0,  mortalityTime: "N/A",                                           procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                }, #I couldn't find a death rate above like .01% anywhere but I can keep looking, also I know Diabetes can cause other conditions that may need surgery, but surgery is not done to cure diabetes
  {condition_id: 3, icd9code: "290.0",   display: "Dementia",                        medication_id: 1,  overnights: "0",     abatementChance: 0,   mortalityChance: 0,  mortalityTime: "N/A",                                           procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                }, #I know dementia can cause other conditions that may need surgery, but surgery is not done to cure dementia
  {condition_id: 4, icd9code: "482.9",   display: "Bacterial Pneumonia",             medication_id: 2,  overnights: "4-6",   abatementChance: 85,  mortalityChance: 12, mortalityTime: "threeWeeks",   recoveryEstimate: "week",        procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                },
  {condition_id: 5, icd9code: "428.0",   display: "Congestive Heart Failure",        medication_id: 3,  overnights: "5-7",   abatementChance: 20,  mortalityChance: 40, mortalityTime: "fourYears",    recoveryEstimate: "sixMonths",   procedureChance: 80, procedureSuccess: 60, procedureDescription: "Surgery to remove blockages from cardiovascular arteries and/or valves"             },
  {condition_id: 6, icd9code: "365.72",  display: "Glaucoma",                        medication_id: 5,  overnights: "0",     abatementChance: 0,   mortalityChance: 0,  mortalityTime: "N/A",                                           procedureChance: 80, procedureSuccess: 0,  procedureDescription: "Laser eye surgery to reduce intraocular pressure"                                   },
  {condition_id: 7, icd9code: "711.90",  display: "Arthritis",                       medication_id: 6,  overnights: "0",     abatementChance: 0,   mortalityChance: 0,  mortalityTime: "N/A",                                           procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                },
  {condition_id: 8, icd9code: "487.8",   display: "Influenza",                       medication_id: 7,  overnights: "3-4",   abatementChance: 85,  mortalityChance: 5,  mortalityTime: "threeWeeks",   recoveryEstimate: "week",        procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                },
  {condition_id: 9, icd9code: "733.01",  display: "Osteoporosis",                    medication_id: 9,  overnights: "0",     abatementChance: 0,   mortalityChance: 5,  mortalityTime: "sevenYears",                                    procedureChance: 20, procedureSuccess: 0,  procedureDescription: "Surgery to reposition broken bone"                                                  }, #Double check
  {condition_id: 10, icd9code: "466.0",  display: "Chronic Bronchitis",              medication_id: 18, overnights: "4-6",   abatementChance: 40,  mortalityChance: 40, mortalityTime: "fourYears",    recoveryEstimate: "week",        procedureChance: 10, procedureSuccess: 20, procedureDescription: "Surgery to remove damaged lung tissue"                                              },
  {condition_id: 11, icd9code: "389.9",  display: "Hearing Loss",                    medication_id: 0,  overnights: "0",     abatementChance: 75,  mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "threeMonths", procedureChance: 20, procedureSuccess: 80, procedureDescription: "Surgery to remove blockages obstructing ear canal"                                  },
  {condition_id: 12, icd9code: "535.00", display: "Gastritis",                       medication_id: 12, overnights: "3-4",   abatementChance: 70,  mortalityChance: 3,  mortalityTime: "twoYears",     recoveryEstimate: "week",        procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                }, #Double check if surgery can actually be helpful
  {condition_id: 13, icd9code: "244.9",  display: "Hypothyroidism",                  medication_id: 13, overnights: "0",     abatementChance: 40,  mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "sixMonths",   procedureChance: 5,  procedureSuccess: 30, procedureDescription: "Surgery to remove parts or all of the thyroid"                                      }, #You can't die from Hypothyroidism, you can die from the complicaitons it causes
  {condition_id: 14, icd9code: "285.9",  display: "Anemia",                          medication_id: 14, overnights: "4-5",   abatementChance: 85,  mortalityChance: 5,  mortalityTime: "twoYears",     recoveryEstimate: "sixMonths",   procedureChance: 25, procedureSuccess: 80, procedureDescription: "Blood transfusion and stem cell transplant"                                         }, #Double check
  {condition_id: 15, icd9code: "492.8",  display: "Emphysema",                       medication_id: 15, overnights: "3-5",   abatementChance: 0,   mortalityChance: 30, mortalityTime: "fourYears",                                     procedureChance: 20, procedureSuccess: 0,  procedureDescription: "Lung volume reduction surgery"                                                      },
  {condition_id: 16, icd9code: "533.30", display: "Peptic Ulcer",                    medication_id: 16, overnights: "6-7",   abatementChance: 80,  mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "threeMonths", procedureChance: 5,  procedureSuccess: 50, procedureDescription: "Widening/removing part of the stomach"                                              },
  {condition_id: 17, icd9code: "554.1",  display: "Varicose Veins",                  medication_id: 17, overnights: "5-7",   abatementChance: 0,   mortalityChance: 0,  mortalityTime: "N/A",                                           procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                },
  {condition_id: 18, icd9code: "362.50", display: "Macular Degeneration",            medication_id: 10, overnights: "0",     abatementChance: 0,   mortalityChance: 0,  mortalityTime: "N/A",                                           procedureChance: 5,  procedureSuccess: 0,  procedureDescription: "Implanted miniature telescope in the patient's eye"                                 },
  {condition_id: 19, icd9code: "274.9",  display: "Gout",                            medication_id: 19, overnights: "4-6",   abatementChance: 90,  mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "sixMonths",   procedureChance: 5,  procedureSuccess: 80, procedureDescription: "Joint replacement and uric acid crystal removal"                                    },
  {condition_id: 20, icd9code: "564.00", display: "Constipation",                    medication_id: 20, overnights: "0",     abatementChance: 100, mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "week",        procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                },
  {condition_id: 21, icd9code: "440.9",  display: "Athersclerosis",                  medication_id: 8,  overnights: "3-5",   abatementChance: 0,   mortalityChance: 0,  mortalityTime: "N/A",                                           procedureChance: 25, procedureSuccess: 0,  procedureDescription: "Surgery to remove plaque from arterial walls"                                       }, #Double check
  {condition_id: 22, icd9code: "416.9",  display: "Pulmonary Heart Disease",         medication_id: 8,  overnights: "5-7",   abatementChance: 30,  mortalityChance: 15, mortalityTime: "twoYears",     recoveryEstimate: "sixMonths",   procedureChance: 15, procedureSuccess: 30, procedureDescription: "Surgery to remove blockages and/or clots in the pulmonary system"                   }, #Double check
  {condition_id: 23, icd9code: "530.81", display: "Esophageal Reflux",               medication_id: 16, overnights: "0",     abatementChance: 70,  mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "threeMonths", procedureChance: 30, procedureSuccess: 90, procedureDescription: "Laparoscopic surgery to reinforce the passage between the esophagus and the stomach"}, #Double check
  {condition_id: 24, icd9code: "003.9",  display: "Salmonella",                      medication_id: 21, overnights: "3-5",   abatementChance: 85,  mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "week",        procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                },
  {condition_id: 25, icd9code: "011.90", display: "Pulmonary Tuberculosis",          medication_id: 22, overnights: "15-20", abatementChance: 80,  mortalityChance: 20, mortalityTime: "threeWeeks",   recoveryEstimate: "sixMonths",   procedureChance: 10, procedureSuccess: 30, procedureDescription: "Surgery to remove pocket(s) of bacteria and repair lung damage"                     },
  {condition_id: 26, icd9code: "265.0",  display: "Beriberi",                        medication_id: 23, overnights: "0",     abatementChance: 100, mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "threeMonths", procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                },
  {condition_id: 27, icd9code: "377.75", display: "Cortical Blindness",              medication_id: 0,  overnights: "1-3",   abatementChance: 0,   mortalityChance: 0,  mortalityTime: "N/A",                                           procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                },
  {condition_id: 28, icd9code: "733.20", display: "Bone Cyst",                       medication_id: 0,  overnights: "4-6",   abatementChance: 90,  mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "sixMonths",   procedureChance: 10, procedureSuccess: 90, procedureDescription: "Drained cyst and filled hole with bone chips from other locations tihin the patient"},
  {condition_id: 28, icd9code: "814.00", display: "Carpal Bone Fracture",            medication_id: 0,  overnights: "0-1",   abatementChance: 100, mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "threeMonths", procedureChance: 40, procedureSuccess: 90, procedureDescription: "Reset the bone and applied a cast"                                                  },
  {condition_id: 29, icd9code: "825.20", display: "Foot Fracture",                   medication_id: 0,  overnights: "0-1",   abatementChance: 100, mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "threeMonths", procedureChance: 40, procedureSuccess: 90, procedureDescription: "Reset the bone and applied a cast"                                                  },
  {condition_id: 30, icd9code: "873.63", display: "Broken Tooth",                    medication_id: 0,  overnights: "0-1",   abatementChance: 100, mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "week",        procedureChance: 20, procedureSuccess: 85, procedureDescription: "Root canal"                                                                         },
  {condition_id: 31, icd9code: "541",    display: "Appendicitis",                    medication_id: 0,  overnights: "3-4",   abatementChance: 100, mortalityChance: 3,  mortalityTime: "threeWeeks",   recoveryEstimate: "week",        procedureChance: 95, procedureSuccess: 90, procedureDescription: "Appendectomy"                                                                       },
  {condition_id: 32, icd9code: "943.01", display: "Forearm Burn",                    medication_id: 0,  overnights: "0-2",   abatementChance: 100, mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "week",        procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                },
  {condition_id: 33, icd9code: "945.06", display: "Thigh Burn",                      medication_id: 0,  overnights: "2-4",   abatementChance: 100, mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "week",        procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                },
  {condition_id: 34, icd9code: "004.2",  display: "Shigella",                        medication_id: 0,  overnights: "4-5",   abatementChance: 90,  mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "week",        procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                },
  {condition_id: 35, icd9code: "023.9",  display: "Brucellosis",                     medication_id: 24, overnights: "10-15", abatementChance: 85,  mortalityChance: 2,  mortalityTime: "threeWeeks",   recoveryEstimate: "sixMonths",   procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                },
  {condition_id: 36, icd9code: "033.0",  display: "Whooping Cough (B. Pertussis)",   medication_id: 25, overnights: "3-4",   abatementChance: 100,  mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "week",        procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                },
  {condition_id: 37, icd9code: "081.9",  display: "Typhus",                          medication_id: 2,  overnights: "3-9",   abatementChance: 85,  mortalityChance: 30, mortalityTime: "threeWeeks",   recoveryEstimate: "threeMonths", procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                },
  {condition_id: 38, icd9code: "072.9",  display: "Mumps",                           medication_id: 0,  overnights: "3-5",   abatementChance: 95,  mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "week",        procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                },
  {condition_id: 39, icd9code: "272.4",  display: "Hyperlipidemia",                  medication_id: 11, overnights: "0",     abatementChance: 70,  mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "sixMonths",   procedureChance: 20, procedureSuccess: 95, procedureDescription: "Gastric Bypass Surgery"                                                             }, #Double check
  {condition_id: 40, icd9code: "781.1",  display: "Disturbances of Smell and Taste", medication_id: 11, overnights: "0",     abatementChance: 100, mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "sixMonths",   procedureChance: 60, procedureSuccess: 75, procedureDescription: "Surgery to restore sensory pathways involving smell and taste"                      },
  {condition_id: 41, icd9code: "162.9",  display: "Lung Cancer",                     medication_id: 29, overnights: "5-7",   abatementChance: 15,  mortalityChance: 70, mortalityTime: "twoYears",     recoveryEstimate: "threeYears",  procedureChance: 40, procedureSuccess: 20, procedureDescription: "Surgery to remove tumors in the thoracic cavity"                                    },
  {condition_id: 42, icd9code: "153.9",  display: "Colon Cancer",                    medication_id: 30, overnights: "8-10",  abatementChance: 70,  mortalityChance: 50, mortalityTime: "twoyears",     recoveryEstimate: "threeYears",  procedureChance: 70, procedureSuccess: 60, procedureDescription: "Surgery to remove a cancerous portion of the colon"                                 },
  {condition_id: 43, icd9code: "172.9",  display: "Skin Cancer (Melanoma)",          medication_id: 31, overnights: "4-6",   abatementChance: 95,  mortalityChance: 20, mortalityTime: "twoYears",     recoveryEstimate: "threeYears",  procedureChance: 75, procedureSuccess: 98, procedureDescription: "Mohs surgery (a form of skin grafting to replace cancerous skin cells)"             },
  {condition_id: 44, icd9code: "585.3",  display: "Chronic Kidney Disease",          medication_id: 0,  overnights: "3-5",   abatementChance: 0,   mortalityChance: 20, mortalityTime: "sevenYears",                                    procedureChance: 10, procedureSuccess: 0,  procedureDescription: "Kidney Transplant"                                                                  },
  {condition_id: 45, icd9code: "155.2",  display: "Liver Cancer",                    medication_id: 32, overnights: "6-8",   abatementChance: 25,  mortalityChance: 85, mortalityTime: "fourYears",    recoveryEstimate: "threeYears",  procedureChance: 25, procedureSuccess: 40, procedureDescription: "Surgery to remove a cancerous portion of the liver"                                 },
  {condition_id: 46, icd9code: "478.9",  display: "Upper Respiratory Tract Disease", medication_id: 15, overnights: "0-1",   abatementChance: 90,  mortalityChance: 2,  mortalityTime: "threeWeeks",   recoveryEstimate: "week",        procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                }, #There may be surgery for this one
  {condition_id: 47, icd9code: "571.5",  display: "Cirrhosis of Liver",              medication_id: 33, overnights: "3-5",   abatementChance: 0,   mortalityChance: 40, mortalityTime: "twoYears",                                      procedureChance: 20, procedureSuccess: 50, procedureDescription: "Liver transplant"                                                                   },
  {condition_id: 48, icd9code: "117.3",  display: "Aspergillosis",                   medication_id: 34, overnights: "20-30", abatementChance: 50,  mortalityChance: 60, mortalityTime: "twoYears",     recoveryEstimate: "threeYears",  procedureChance: 10, procedureSuccess: 40, procedureDescription: "Surgery to drain and/or remove lung mass"                                           },
  {condition_id: 49, icd9code: "136.0",  display: "Ainhum",                          medication_id: 0,  overnights: "0",     abatementChance: 0,   mortalityChance: 0,  mortalityTime: "N/A",                                           procedureChance: 60, procedureSuccess: 30, procedureDescription: "Toe amputation"                                                                     },
  {condition_id: 50, icd9code: "266.0",  display: "Ariboflavinosis",                 medication_id: 0,  overnights: "0",     abatementChance: 100, mortalityChance: 0,  mortalityTime: "N/A",          recoveryEstimate: "threeMonths", procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                },
  {condition_id: 51, icd9code: "276.2",  display: "Acidosis",                        medication_id: 35, overnights: "0-1",   abatementChance: 90,  mortalityChance: 5,  mortalityTime: "twoYears",     recoveryEstimate: "threeYears",  procedureChance: 0,  procedureSuccess: 0,  procedureDescription: "N/A"                                                                                }, #Double check
  {condition_id: 52, icd9code: "571.2",  display: "Alcoholic Cirrhosis of Liver",    medication_id: 33, overnights: "5-7",   abatementChance: 0,   mortalityChance: 40, mortalityTime: "twoYears",                                      procedureChance: 10, procedureSuccess: 50, procedureDescription: "Liver transplant"                                                                   },
  {condition_id: 53, icd9code: "185",    display: "Prostate Cancer",                 medication_id: 27, overnights: "2-4",   abatementChance: 90,  mortalityChance: 19, mortalityTime: "twoYears",     recoveryEstimate: "threeYears",  procedureChance: 75, procedureSuccess: 98, procedureDescription: "Radical Prostatectomy"                                                              },
  {condition_id: 54, icd9code: "174.9",  display: "Breast Cancer",                   medication_id: 28, overnights: "2-3",   abatementChance: 40,  mortalityChance: 24, mortalityTime: "twoYears",     recoveryEstimate: "threeYears",  procedureChance: 60, procedureSuccess: 60, procedureDescription: "Surgery to remove part or all of a cancerous breast"                                }
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

#This 'if' statement makes emphysema and lung cancer and respiratory tract disease more likely if the patient is a smoker
if smokingChoice == 2
  unless conditionIndex == 3
    unless conditionIndex == 7
      emphysemaChance = rand(5)
        if emphysemaChance == 4
          conditionIndex = 14
        end
    end
  end
end
if allConditions.include? ("Emphysema")
  lungCancerChance = rand(3)
  if lungCancerChance == 2
    conditionIndex = 41
  end
end
if allConditions.include? ("Emphysema")
  unless conditionIndex == 41
    respiratoryDiseaseChance = rand(4)
    if respiratoryDiseaseChance == 3
      conditionIndex = 46
    end
  end
end
if allConditions.include? ("Emphysema")
  unless conditionIndex == 41 || 46
    bronchitisChance = rand(4)
    if bronchitisChance == 3
      conditionIndex = 9
    end
  end
end

#This 'if/else' statement makes liver disease more likely if the patients are heavy drinkers (decided in observations)
if patientDrinkingStatus == 2
  unless conditionIndex == 3 || 7 || 14 || 41 || 46
    liverDiseaseChance = rand(4)
    if liverDiseaseChance == 3
      conditionIndex = 44
    elsif liverDiseaseChance == 2
      conditionIndex = 46
    end
  end
end

#This 'if/else' statement ensures that patients have the Alcohlic Cirrhosis condition if and only if they are heavy drinkers (decided in observations)
unless patientDrinkingStatus == 2
  while conditionRepository[conditionIndex][:display] == "Alcoholic Cirrhosis of Liver"
    conditionIndex = rand(allConditions.count - 3) - 1
  end
end
if patientDrinkingStatus == 2
  if conditionRepository[conditionIndex][:display] == "Alcoholic Cirrhosis of Liver"
#Make sure this is up to date, the following line should lead to "Alcohlic Cirrhosis of Liver"
    conditionIndex = 51
  end
end

#This 'if/else' statement makes heart disease more common if the patients have hypertension
if bpChoice == "Hypertension"
  heartDiseaseChance = rand(5)
  if heartDiseaseChance == 2
    conditionIndex = 5
  elsif heartDiseaseChance == 3
    conditionIndex = 22
  end
end

#These 'if/else' statements ensures that only men can have prostate cancer and only women can have breast cancer (because it is super unlikely for men)
if $genderChoice == "male"
  while conditionRepository[conditionIndex][:display] == "Breast Cancer"
    conditionIndex = rand(allConditions.count - 2) - 1
  end
else
  while conditionRepository[conditionIndex][:display] == "Prostate Cancer"
    conditionIndex = rand(allConditions.count - 2) - 1
  end
end

#This code avoids duplicates for hypertension and diabetes (because I could only get it to work if they came after the duplicate-condition-preventer right above this)
#Diabetes and hypertension get their own specification because they are directly related to the observations patientGlucose and bloodPressure (respectively)
#These first two lines are just setting the variables for the first time through the condition-creating loop
if conditionCounter == 1
  hasDiabetes = false
  hasHypertension = false
else
  allConditions.each do |condition|
    if condition.code.text == "Diabetes"
      hasDiabetes = true
    end
    if condition.code.text == "Hypertension"
      hasHypertension = true
    end
  end
end

#This 'if/else' statement ensures that patients have the Diabetes condition if and only if they have high blood glucose levels (decided in observations)
unless hasDiabetes == true
  if patientGlucose.valueQuantity.value >= 200
    conditionIndex = 1
  else
    if conditionIndex == 1
      conditionIndex = rand(3..conditionRepository.count-3) - 1
    end
  end
end

#This 'if/else' statement ensures that patients have the Hypertension condition if and only if they have high blood pressure (decided in observations)
unless hasHypertension == true
  if bpChoice == "Hypertension"
    conditionIndex = 0
    hasHypertension = true
  else
    if conditionCounter > 1
      conditionIndex = rand(3..conditionRepository.count-3) - 1
    end
  end
end


#This code iterates through the allConditions array and chooses a new conditionIndex if the patient already had that condition
#Essentially it prevents duplicate conditions
if conditionCounter > 1
  if hasDiabetes == true && hasHypertension == true
    if conditionCounter > 2
      allConditions.each do |condition|
        if condition.code.coding[0].code == conditionRepository[conditionIndex][:icd9code]
          conditionIndex = rand(2..conditionRepository.count-3) - 1
        end
      end
    end
  else
    allConditions.each do |condition|
      if condition.code.coding[0].code == conditionRepository[conditionIndex][:icd9code]
        conditionIndex = rand(2..conditionRepository.count-3) - 1
      end
    end
  end
end

#This code establishes when exactly the condition is diagnosed
dateAssertedVar = Faker::Date.between(3.years.ago, Date.today)

if conditionCounter == 1
  earliestDateAsserted = dateAssertedVar
else
  if dateAssertedVar < earliestDateAsserted
    earliestDateAsserted = dateAssertedVar
  end
end

#This code will determine if the patient died from this condition
deathChance = rand(100)
if deathChance < conditionRepository[conditionIndex][:mortalityChance]
  case conditionRepository[conditionIndex][:mortalityTime]
  when "threeWeeks"
    potentialDeceasedDateTime = dateAssertedVar + rand(15..25).days
  when "twoYears"
    potentialDeceasedDateTime = dateAssertedVar + rand(1..2).years + rand(0..11).months + rand(0..27).days
  when "fourYears"
    potentialDeceasedDateTime = dateAssertedVar + rand(3..4).years + rand(0..11).months + rand(0..27).days
  when "sevenYears"
    potentialDeceasedDateTime = dateAssertedVar + rand(6..7).years + rand(0..11).months + rand(0..27).days
  end
  if potentialDeceasedDateTime.to_s <= Date.today.to_s
    if mockPatient.deceasedBoolean == true
      if potentialDeceasedDateTime.to_s < mockPatient.deceasedDateTime.to_s
        mockPatient.deceasedDateTime = potentialDeceasedDateTime
        causeOfDeathVar = conditionRepository[conditionIndex][:display]
      end
    else
      mockPatient.deceasedDateTime = potentialDeceasedDateTime
      causeOfDeathVar = conditionRepository[conditionIndex][:display]
    end
    mockPatient.deceasedBoolean = true
  end
end
#end


#This code essentially takes the information from the indexed condition in the repository and translates it to FHIR format
conditionDisplayVar = conditionRepository[conditionIndex][:display]
conditionCodeVar = conditionRepository[conditionIndex][:icd9code]
mockCondition.code = {coding: [{system: "http://hl7.org/fhir/sid/icd-9", code: conditionCodeVar, display: conditionDisplayVar}], text: conditionDisplayVar}
mockCondition.category = {coding: [{system: "http://hl7.org/fhir/condition-category", code: "diagnosis", display: "Diagnosis"}]}
mockCondition.status = "confirmed"
recoveryEstimateVar = conditionRepository[conditionIndex][:recoveryEstimate]

#This block of code determines the asserted and abatement dates of the condition
mockCondition.dateAsserted = dateAssertedVar
abatementChanceVar = rand(1..99)
if conditionRepository[conditionIndex][:abatementChance] > abatementChanceVar
  if recoveryEstimateVar == "threeYears"
    abatementDateVar = dateAssertedVar + rand(2..4).years + rand(0..11).months + rand(0..27).days
  elsif recoveryEstimateVar == "sixMonths"
    abatementDateVar = dateAssertedVar + rand(5..7).months + rand(0..20).days
  elsif recoveryEstimateVar == "threeMonths"
    abatementDateVar = dateAssertedVar + rand(2..3).months + rand(0..20).days
  elsif recoveryEstimateVar == "week"
    abatementDateVar = dateAssertedVar + rand(6..10).days
  else
    return "Error: Recovery Estimate for this condition is not supported"
  end
  #The following code ensures that a condition does not have an abatement date in the future or after the patient's deceased date
  if abatementDateVar > Date.today
    mockCondition.abatementBoolean = false
  elsif abatementDateVar.to_s > mockPatient.deceasedDateTime.to_s
    mockCondition.abatementBoolean = false
  else
    mockCondition.abatementBoolean = true
    mockCondition.abatementDate = abatementDateVar
  end
else
  mockCondition.abatementBoolean = false
end








#MockEncounters#########################################################################################################################################################################################################################################################################################################
########################################################################################################################################################################################################################################################################################################################
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
  mockEncounter.identifier = [{"use" => "usual", "label" => mockPatient.name[0].given[0][0].split(" ").first.chomp << "'s visit on " << dateAssertedVar.to_s}]
else
  mockEncounter.identifier = [{"use" => "usual", "label" => mockPatient.name[0].given[0][0].split(" ").first.chomp << "'s overnight visit from " << dateAssertedVar.to_s << " to " << (dateAssertedVar + stayPeriod).to_s}]
end

mockEncounter.subject = {"display" => mockPatient.name[0].given[0][0].split(" ").first.chomp << " " << mockPatient.name[0].family[0][0]}
if conditionRepository[conditionIndex][:overnights] == "0"
  mockEncounter.period = {"start" => dateAssertedVar, "end" => dateAssertedVar + rand(6).hours + rand(60).minutes + rand(60).seconds}
else
  #This code takes the string value from the :overnights key in the conditionRepository and translates it to create a period for the encounter
  lowStayPeriod = conditionRepository[conditionIndex][:overnights].split("-").first.to_i
  highStayPeriod = conditionRepository[conditionIndex][:overnights].split("-").second.to_i
  stayPeriod = rand(lowStayPeriod..highStayPeriod)
  mockEncounter.period = {"start" => dateAssertedVar, "end" => dateAssertedVar + stayPeriod}
end
if mockEncounter.period.end <= Date.today
  mockEncounter.status = "finished"
else
  mockEncounter.status = "in progress"
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
    mockEncounter.reason = {"text" => "#{mockPatient.name[0].given[0][0].split(" ").first.chomp} #{mockPatient.name[0].family[0][0]} came in for a non-overnight visit where he was diagnosed with #{mockCondition.code.text}."}
  else
    mockEncounter.reason = {"text" => "#{mockPatient.name[0].given[0][0].split(" ").first.chomp} #{mockPatient.name[0].family[0][0]} came in for a non-overnight visit where she was diagnosed with #{mockCondition.code.text}."}
  end
else
  #This 'if' statement just determines whether to use 'he' or 'she' in the mock.Encounter.text
  if $genderChoice == "male"
    mockEncounter.reason = {"text" => "#{mockPatient.name[0].given[0][0].split(" ").first.chomp} #{mockPatient.name[0].family[0][0]} stayed for #{stayPeriod} nights after being diagnosed with #{mockCondition.code.text}."}
  else
    mockEncounter.reason = {"text" => "#{mockPatient.name[0].given[0][0].split(" ").first.chomp} #{mockPatient.name[0].family[0][0]} stayed for a #{stayPeriod} nights after being diagnosed with #{mockCondition.code.text}."}
  end
end








#MockProcedures###########################################################################################################################################################################################################################################################################################################
##########################################################################################################################################################################################################################################################################################################################
def createProcedure()
  newProcedure = FHIR::Procedure.new()
end

mockProcedure = createProcedure()

#This code dictates whether the patient will undergo a procedure depending on how likely/effective surgery is for the specific condition diagnosed
procedurePossibility = rand(1..100)
if procedurePossibility <= conditionRepository[conditionIndex][:procedureChance]
  mockProcedure.indication[0] = {"text" => "#{conditionRepository[conditionIndex][:procedureDescription]}"}
  mockProcedure.encounter = {"display" => "#{mockEncounter.identifier[0].label}"}
  #The following lines were not recognized by the FHIR format on Github, but the website said it should be
#  mockProcedure.status = "completed"
#  mockProcedure.type = {text: "#{conditionRepository[conditionIndex][:procedureDescription]}"}
    #The following line should be uncommented if I want to assign codes for procedures
    #mockProcedure.type = {"coding" => [{"system" => "#", "code" => "#", "display" => "#"}], text: "#{conditionRepository[conditionIndex][:procedureDescription]}"}
  #The following line should maybe be mockProcedure.performedDateTime = mockEncounter.period.start
  mockProcedure.notes = "completed"
  mockProcedure.date = mockEncounter.period
  mockProcedure.date.end = mockProcedure.date.start + rand(5..9).hours


  #The following code takes into account the procedureSuccess rate and increases the chance of abatement accordingly
  if mockCondition.abatementBoolean == false
    if conditionRepository[conditionIndex][:abatementChance] < abatementChanceVar
      unless conditionRepository[conditionIndex][:abatementChance] == 0
        procedureAbatementPossibility = rand(1..100)
        if procedureAbatementPossibility <= conditionRepository[conditionIndex][:procedureSuccess]
          mockCondition.abatementBoolean = true
          if recoveryEstimateVar == "threeYears"
            abatementDateVar = dateAssertedVar + rand(2..4).years + rand(0..11).months + rand(0..27).days
          elsif recoveryEstimateVar == "sixMonths"
            abatementDateVar = dateAssertedVar + rand(5..7).months + rand(0..20).days
          elsif recoveryEstimateVar == "threeMonths"
            abatementDateVar = dateAssertedVar + rand(2..3).months + rand(0..20).days
          elsif recoveryEstimateVar == "week"
            abatementDateVar = dateAssertedVar + rand(6..10).days
          else
            return "Error: Recovery Estimate for this condition is not supported"
          end
        #The following code ensures that a condition does not have an abatement date in the future or after the patient's deceased date
          if abatementDateVar > Date.today
            mockCondition.abatementBoolean = false
          elsif abatementDateVar.to_s > mockPatient.deceasedDateTime.to_s
            mockCondition.abatementBoolean = false
          else
            mockCondition.abatementBoolean = true
            mockCondition.abatementDate = abatementDateVar
          end
        else
          mockCondition.abatementBoolean = false
        end
      end
    end
  end
end









#MockMedications##########################################################################################################################################################################################################################################################################################
#########################################################################################################################################################################################################################################################################################################
def createMedication()
  newMedication = FHIR::Medication.new()
end

#This is the repository of medications; as of now the indices correspond with those of their corresponding diseases
#If the medication is taken as needed, the rate is the maximum suggested dosage
#The rate symbol has seemingly unecessary spaces, but they are needed for cutting the string into pieces for the MedicationStatement
medicationRepository = [
  {medication_id: 1,  rxNormCode: "997224",  brandName: "Aricept",                     brand?: true,  "tradeName" => "Donepezil Hydrochloride 10mg Oral Tablet",                              asNeeded: false, rate: "10 mg / day"},
  {medication_id: 2,  rxNormCode: "141962",  brandName: "N/A",                         brand?: false, "tradeName" => "Azithromycin 250mg Oral Capsule",                                       asNeeded: false, rate: "500 mg / day"},
  {medication_id: 3,  rxNormCode: "104376",  brandName: "Zestril",                     brand?: true,  "tradeName" => "Lisinopril 5mg Oral Tablet",                                            asNeeded: false, rate: "5 mg / day"},
  {medication_id: 4,  rxNormCode: "860998",  brandName: "Fortamet",                    brand?: true,  "tradeName" => "Metformin Hydrochloride 1000mg Extended Release Oral Tablet",           asNeeded: false, rate: "1000 mg / day"},
  {medication_id: 5,  rxNormCode: "1186297", brandName: "XALATAN Ophthalmic Solution", brand?: true,  "tradeName" => "N/A",                                                                   asNeeded: false, rate: "1 drop / day"},
  {medication_id: 6,  rxNormCode: "369070",  brandName: "Tylenol",                     brand?: true,  "tradeName" => "Acetaminophen 650mg Tablet",                                            asNeeded: true,  rate: "3900 mg / day"},
  {medication_id: 7,  rxNormCode: "261315",  brandName: "TamilFlu",                    brand?: true,  "tradeName" => "Oseltamivir 75mg Oral Tablet",                                          asNeeded: false, rate: "150 mg / day"},
  {medication_id: 8,  rxNormCode: "104377",  brandName: "Zestril",                     brand?: true,  "tradeName" => "Lisinopril 10mg Oral Tablet",                                           asNeeded: false, rate: "10 mg / day"},
  {medication_id: 9,  rxNormCode: "904421",  brandName: "Fosamax",                     brand?: true,  "tradeName" => "Alendronate 10mg Oral Tablet",                                          asNeeded: false, rate: "10 mg / day"},
  {medication_id: 10, rxNormCode: "644300",  brandName: "Lucentis",                    brand?: true,  "tradeName" => "Ranibizumab Injectable Solution",                                       asNeeded: false, rate: "0.5 mg / month"},
  {medication_id: 11, rxNormCode: "617310",  brandName: "N/A",                         brand?: false, "tradeName" => "Atorvastatin 20mg Oral Tablet",                                         asNeeded: false, rate: "20 mg / day"},
  {medication_id: 12, rxNormCode: "197517",  brandName: "N/A",                         brand?: false, "tradeName" => "Clarithromycin 500mg Oral Tablet",                                      asNeeded: false, rate: "500 mg / day"},
  {medication_id: 13, rxNormCode: "966180",  brandName: "Levothroid",                  brand?: true,  "tradeName" => "Levothyroxine Sodium 0.1mg Oral Tablet",                                asNeeded: false, rate: "0.1 mg / day"},
  {medication_id: 14, rxNormCode: "849612",  brandName: "Bifera",                      brand?: true,  "tradeName" => "FE HEME Polypeptide 6mg/Polysaccharide Iron Complex 22 MG Oral Tablet", asNeeded: false, rate: "6 mg / day"},
  {medication_id: 15, rxNormCode: "198145",  brandName: "N/A",                         brand?: false, "tradeName" => "Prednisone 10mg Oral Tablet",                                           asNeeded: false, rate: "10 mg / day"},
  {medication_id: 16, rxNormCode: "902622",  brandName: "Dexilant",                    brand?: true,  "tradeName" => "Dexlansoprazole 30mg",                                                  asNeeded: false, rate: "30 mg / day"},
  {medication_id: 17, rxNormCode: "968177",  brandName: "Asclera",                     brand?: true,  "tradeName" => "Polidocanol 5mg/mL",                                                    asNeeded: false, rate: "10 mL / week"},
  {medication_id: 18, rxNormCode: "203948",  brandName: "Amoxil",                      brand?: true,  "tradeName" => "Amoxicillin 250mg Oral Capsule",                                        asNeeded: false, rate: "1000 mg / day"},
  {medication_id: 19, rxNormCode: "197540",  brandName: "N/A",                         brand?: false, "tradeName" => "Colchicine 0.5mg Oral Tablet",                                          asNeeded: false, rate: "0.5 mg / day"},
  {medication_id: 20, rxNormCode: "1247761", brandName: "Colace",                      brand?: true,  "tradeName" => "Docusate Sodium 50mg Oral Capsule",                                     asNeeded: true,  rate: "300 mg / day"},
  {medication_id: 21, rxNormCode: "978013",  brandName: "Imodium",                     brand?: true,  "tradeName" => "Loperamide Hydrochloride 2mg Oral Capsule",                             asNeeded: true,  rate: "16 mg / day"},
  {medication_id: 22, rxNormCode: "197832",  brandName: "N/A",                         brand?: false, "tradeName" => "Isoniazid 300mg Oral Tablet",                                           asNeeded: false, rate: "300 mg / day"},
  {medication_id: 23, rxNormCode: "316812",  brandName: "N/A",                         brand?: false, "tradeName" => "Thiamine 50mg",                                                         asNeeded: false, rate: "50 mg / day"},
  {medication_id: 24, rxNormCode: "562918",  brandName: "Sumycin",                     brand?: true,  "tradeName" => "Tetracycline 500mg",                                                    asNeeded: false, rate: "500 mg / day"},
  {medication_id: 25, rxNormCode: "317364",  brandName: "N/A",                         brand?: false, "tradeName" => "Erythromycin 250mg",                                                    asNeeded: false, rate: "250 mg / day"},
  {medication_id: 26, rxNormCode: "884319",  brandName: "Zosyn",                       brand?: true,  "tradeName" => "Piperacillin Injectable Solution",                                      asNeeded: false, rate: "15 g / day"},
  {medication_id: 27, rxNormCode: "858123",  brandName: "Firmagon",                    brand?: true,  "tradeName" => "Degarelix Injectable Solution",                                         asNeeded: false, rate: "80 g / month"},
  {medication_id: 28, rxNormCode: "371664",  brandName: "N/A",                         brand?: false, "tradeName" => "Cyclophosphamide Oral Tablet",                                          asNeeded: false, rate: "300 mg / day"},
  {medication_id: 29, rxNormCode: "349472",  brandName: "N/A",                         brand?: false, "tradeName" => "Gefitinib 250mg Oral Tablet",                                           asNeeded: false, rate: "250 mg / day"},
  {medication_id: 30, rxNormCode: "544557",  brandName: "Avastin",                     brand?: true,  "tradeName" => "Bevacizumab Injectable Solution",                                       asNeeded: false, rate: (patientWeightInKg*10).to_s << " mg / week"}, #This should not be administered until 28 days after surgery(encounter)
  {medication_id: 31, rxNormCode: "1094839", brandName: "Yervoy",                      brand?: true,  "tradeName" => "Ipilimumab Injectable Solution",                                        asNeeded: false, rate: (patientWeightInKg*3).to_s << " mg / month"}, #This should only be taken for four months
  {medication_id: 32, rxNormCode: "615978",  brandName: "Nexavar",                     brand?: true,  "tradeName" => "Sorafenib Oral Tablet",                                                 asNeeded: true,  rate: "400 mg / day"},
  {medication_id: 33, rxNormCode: "858748",  brandName: "Actigall",                    brand?: true,  "tradeName" => "Ursodiol Oral Product",                                                 asNeeded: false, rate: (patientWeightInKg*10).to_s << " mg / day"},
  {medication_id: 34, rxNormCode: "352219",  brandName: "Vfend",                       brand?: true,  "tradeName" => "Voriconazole 200mg Oral Tablet",                                        asNeeded: false, rate: "200 mg / day"},
  {medication_id: 35, rxNormCode: "630974",  brandName: "N/A",                         brand?: false, "tradeName" => "Sodium Bicarbonate 500mg",                                              asNeeded: false, rate: "500mg / day"}
  ]

  #This code creates a medication and then takes the information from the medication repository that corresponds to the previously created disease
  mockMedication = createMedication()

  #This 'unless' statement is for conditions that don't have medications (in which case the loop will omit the medication and MedicationStatement sections)
  #This 'unless' statement comes after the the medication is created so even non-medications have place holders for when post-mortem conditions are deleted at the end of the script
  unless conditionRepository[conditionIndex][:medication_id] == 0

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

  #This is the end to the 'unless' statement that skipped the assignment of medication attributes if there is no medication for the assigned condition
  end








#MedicationStatment####################################################################################################################################################################################################################################################################################################
########################################################################################################################################################################################################################################################################################################################
def createMedicationStatement()
  newMedicationStatement = FHIR::MedicationStatement.new()
end

#This code creates a medication statement that summarizes all of the assigned medications and whether or not the prescriptions are still active
mockMedicationStatement = createMedicationStatement()

#This 'unless' statement comes after the the medication is created so even non-medications have place holders for when post-mortem conditions are deleted at the end of the script
unless conditionRepository[conditionIndex][:medication_id] == 0

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

#The following 'end' closes the 'unless' statement that omits medicationStatements when the condition has no medication
end









#Adding Condition/Medication/Statement/Encounter to Profile Arrays##################################################################################################################################################################################################################################################################################################
####################################################################################################################################################################################################################################################################################################################################################################
allConditions << mockCondition
allEncounters << mockEncounter
allMedications << mockMedication
allMedicationStatements << mockMedicationStatement
allProcedures << mockProcedure

#Below is the end of the 'until' loop that creates the conditions and their corresponding medications amedication statements
end

#This code creates the possibility that the patient dies from natural causes
unless mockPatient.deceasedBoolean == true
  naturalDeathChance = rand(20)
  if naturalDeathChance == 8
    causeOfDeathVar = "Natural Causes"
    mockPatient.deceasedBoolean = true
    mockPatient.deceasedDateTime = Faker::Date.between(3.years.ago,Date.today)
  end
end

if mockPatient.deceasedDateTime
#This code removes conditions/medications that were created, but occured before this mockPatient.deceasedDateTime
deletedConditions = []
deletedConditionIteratorCounter = 0
allConditions.each do |condition|
  if condition.dateAsserted > mockPatient.deceasedDateTime
    deletedConditions.push(allConditions[deletedConditionIteratorCounter])
    allConditions.delete(allConditions[deletedConditionIteratorCounter])
    allMedications.delete(allMedications[deletedConditionIteratorCounter])
    allMedicationStatements.delete(allMedicationStatements[deletedConditionIteratorCounter])
    allEncounters.delete(allEncounters[deletedConditionIteratorCounter])
#    allProcedures.delete(allProcedures[deletedConditionIteratorCounter]) ########################################################################################################################################################################################################
  end
  deletedConditionIteratorCounter += 1
end
end

#This code deletes the placeholders in the allMedications,allMedicationsStatement,and allProcedures arrays that don't actually contain medications/statements/procedures
allMedications.each do |medication|
  unless medication.kind == "Product"
    allMedications.delete(medication)
  end
end
allMedicationStatements.each do |medicationStatement|
  unless medicationStatement.wasNotGiven == false
    allMedicationStatements.delete(medicationStatement)
  end
end
allProcedures.each do |procedure|
  unless procedure.notes == "completed"
    allProcedures.delete(procedure)
  end
end

#This code creates encounter that are not associated with the diagnosis of a disease, for example, a yearly physical
if numberOfConditions == 0
  earliestEncounterDate = Faker::Date.between(3.years.ago,Date.today)
else
  earliestEncounterDate = earliestDateAsserted - rand(2..4).months - rand(0..30).days
end
if mockPatient.deceasedBoolean == true
  numberOfExtraEncounters = mockPatient.deceasedDateTime.to_s[0..3].to_i - earliestEncounterDate.to_s[0..3].to_i
  if earliestEncounterDate.to_s[5..9] > mockPatient.deceasedDateTime.to_s[5..9]
    numberOfExtraEncounters -= 1
  end
else
  numberOfExtraEncounters = Date.today.to_s[0..3].to_i - earliestEncounterDate.to_s[0..3].to_i + 1
  if earliestEncounterDate.to_s[5..9] > Date.today.to_s[5..9]
    numberOfExtraEncounters -= 1
  end
end








#MockExtraEncounters##################################################################################################################################################################################################################################################################################################
#####################################################################################################################################################################################################################################################################################################################

extraEncounterCounter = 0
allExtraEncounters = []
until extraEncounterCounter == numberOfExtraEncounters
  extraEncounterCounter += 1
  mockExtraEncounter = createEncounter()
  extraEncounterDate = earliestEncounterDate + (extraEncounterCounter-1).years + rand(-10..10).days
  mockExtraEncounter.subject = {"display" => mockPatient.name[0].given[0][0].split(" ").first.chomp << " " << mockPatient.name[0].family[0][0].split(" ").first.chomp}
#CHECK TIME OF START
  mockExtraEncounter.period = {"start" => extraEncounterDate, "end" => extraEncounterDate + rand(6).hours + rand(60).minutes + rand(60).seconds}
  mockExtraEncounter.identifier = [{"use" => "usual", "label" => mockPatient.name[0].given[0][0].split(" ").first.chomp << "'s yearly physical on " << mockExtraEncounter.period.start.to_s}]
  mockExtraEncounter.hospitalization = {"reAdmission" => false}
  mockExtraEncounter.reason = {"text" => "#{mockPatient.name[0].given[0][0].split(" ").first.chomp} #{mockPatient.name[0].family[0][0].split(" ").first.chomp} came in for a yearly physical."}
  mockExtraEncounter.serviceProvider = {"display" => "Medstar Health"}
  if mockExtraEncounter.period.end <= Date.today
    mockExtraEncounter.status = "finished"
  else
    mockExtraEncounter.status = "in progress"
  end
  allExtraEncounters << mockExtraEncounter
end
allExtraEncounters.each do |extraEncounter|
  allEncounters << extraEncounter
end

#This code assigns each observation with an issued date
#These observations were issued during the first encounter
patientHeight.issued = earliestEncounterDate + rand(10..14).hours + rand(0..59).minutes
patientWeight.issued = earliestEncounterDate + rand(10..14).hours + rand(0..59).minutes
patientBMI.issued = earliestEncounterDate + rand(10..14).hours + rand(0..59).minutes
#These observations can essentially change and/or be updated so they will be issued at any random extraEncounter (yearlyPhysical)
patientSmokingStatus.issued = allExtraEncounters[rand(allExtraEncounters.count-1)].period.start + rand(10..14).hours + rand(0..59).minutes
patientDrinkingStatus.issued = allExtraEncounters[rand(allExtraEncounters.count-1)].period.start + rand(10..14).hours + rand(0..59).minutes
patientHDL.issued = allExtraEncounters[rand(allExtraEncounters.count-1)].period.start + rand(10..14).hours + rand(0..59).minutes
patientLDL.issued = allExtraEncounters[rand(allExtraEncounters.count-1)].period.start + rand(10..14).hours + rand(0..59).minutes
patientTriglyceride.issued = allExtraEncounters[rand(allExtraEncounters.count-1)].period.start + rand(10..14).hours + rand(0..59).minutes
#If the patient has diabetes or hypertension, the glucose and blood pressure observations will be issued the same date the diabetes and hypertension, respectively, were asserted
if hasDiabetes == true
  if hasHypertension == true
    patientGlucose.issued = allConditions[1].dateAsserted + rand(10..14).hours + rand(0..59).minutes
  else
    patientGlucose.issued = allConditions[0].dateAsserted + rand(10..14).hours + rand(0..59).minutes
  end
else
  patientGlucose.issued = allExtraEncounters[rand(allExtraEncounters.count-1)].period.start + rand(10..14).hours + rand(0..59).minutes
end
if hasHypertension == true
  patientSystolicBloodPressure.issued = allConditions[0].dateAsserted + rand(10..14).hours + rand(0..59).minutes
  patientDiastolicBloodPressure.issued = allConditions[0].dateAsserted + rand(10..14).hours + rand(0..59).minutes
else
  patientSystolicBloodPressure.issued = allExtraEncounters[rand(allExtraEncounters.count-1)].period.start + rand(10..14).hours + rand(0..59).minutes
  patientDiastolicBloodPressure.issued = allExtraEncounters[rand(allExtraEncounters.count-1)].period.start + rand(10..14).hours + rand(0..59).minutes
end







#This code dictates whether or not the patient record is active based on if they are deceased or not
if mockPatient.deceasedBoolean == true
  mockPatient.active = false
  #I want to add a cause of death field, but I can't find anywhere to put it
  #mockPatient.notes = "Cause of Death: #{causeOfDeathVar}"
else
  mockPatient.active = true
end

binding.pry

puts mockPatient.to_fhir_json
