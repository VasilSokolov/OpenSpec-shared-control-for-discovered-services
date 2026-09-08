# Translation reference — QCT-4690

This file is the temporary local source of truth for the complete translation
table supplied with the change. Use it for the current specification and
implementation until the Google Drive MCP is enabled. When Drive access is
enabled, compare the remote sheet against this file and record any differences
before updating the specification.

Source: user-provided translation table, imported 2026-09-05.
Scope for the current change: only the first contract-fields part approved for
QCT-4690. Other rows remain preserved here for future changes and must not be
implemented by this change unless the Jira scope is expanded and approved.

```tsv
Translation key	Section	Description	Translation English	Translation German	Field/text 	Example	Required	Can be prefilled	Field type	Logic 	Comments
I18N.DIGITALCONTRACT.informationBoxHeader	Information Box	Header of the information box at the top of the contract	mobile.de Sales Contract	mobile.de Kaufvertrag	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.informationBoxBodySeller	Information Box	Body of the information box at the top of the contract for the seller	The mobile.de sales contract ensures a secure transaction when you sell your vehicle!	Der mobile.de Kaufvertrag ist der sichere Abschluss deines Fahrzeugverkaufs!	Body (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.informationBoxBodyBuyer		Body of the information box at the top of the contract for the buyer	The mobile.de sales contract ensures a secure transaction when you buy a vehicle!	Der mobile.de Kaufvertrag ist der sichere Abschluss deines Fahrzeugkaufs!	Body (text)		FALSE	FALSE			
I18N.COMMON.MDE_UI.HEADER.Learn more	Information Box	Text link in the information box at the top of the contract	Learn more	Mehr erfahren			FALSE	FALSE			
digitalContract.header		Header of the contract section	Digital sales contract	Digitaler Kaufvertrag	Header (text)		FALSE	FALSE			
digitalContract.Body		Body below the header of the contract	Important: This contract applies only to sales between private individuals.	Wichtig: Dieser Vertrag gilt ausschließlich für Verkäufe zwischen Privatpersonen.	Body (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.initiatorActionsHeader	Initiator Actions Box	Header of the initiator actions box at the top right of the contract (change language + delete contract)	Your contract options	Deine Vertragsoptionen	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.initiatorActionsBody	Initiator Actions Box	Body of the initiator actions box at the top right of the contract (change language + delete contract)	Only you can view, change, and perform the following actions:	Nur du kannst die folgenden Optionen sehen, ändern und ausführen:	Body (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.initiatorActionsChangeLanguage	Initiator Actions Box	Change language action of the initiator actions box at the top right of the contract (change language + delete contract)	Change language	Sprache ändern	Button		FALSE	FALSE			
I18N.DIGITALCONTRACT.initiatorActionsDeleteContract	Initiator Actions Box	Delete contract action of the initiator actions box at the top right of the contract (change language + delete contract)	Delete contract	Vertrag löschen	Button		FALSE	FALSE			
I18N.DIGITALCONTRACT.stickyBoxHeader	Sticky Box/ Contract Progress Box	Header of the sticky box with the contract progress and sign/share buttons	Contract progress	Vertragsfortschritt	Header (text)		FALSE	FALSE			
I18N.SYI_02.Seller	Sticky Box/ Contract Progress Box	Seller Header in the sticky box with the contract progress and sign/share buttons	Seller	Verkäufer	Header (text)		FALSE	FALSE			
I18N.COMMON.Vehicle	Sticky Box/ Contract Progress Box	Vehicle Header in the sticky box with the contract progress and sign/share buttons	Vehicle	Fahrzeug	Header (text)		FALSE	FALSE			
I18N.COMMON.Buyer	Sticky Box/ Contract Progress Box	Buyer Header in the sticky box with the contract progress and sign/share buttons	Buyer	Käufer	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.stickyBoxProgressHandover	Sticky Box/ Contract Progress Box	Handover Header in the sticky box with the contract progress and sign/share buttons	Handover	Übergabe	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.stickyBoxProgressPrice	Sticky Box/ Contract Progress Box	Price Header in the sticky box with the contract progress and sign/share buttons	Price and payment	Kaufpreis und Zahlung	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.stickyBoxProgressSigning	Sticky Box/ Contract Progress Box	Signing Header in the sticky box with the contract progress and sign/share buttons	Signing	Unterzeichnung	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.stickyBoxButton1	Sticky Box/ Contract Progress Box	Send contract button in the sticky box with the contract progress and sign/share buttons	Send contract to buyer	Vertrag an Käufer senden	Button		FALSE	FALSE			
I18N.DIGITALCONTRACT.stickyBoxButton2	Sticky Box/ Contract Progress Box	Sign contract button in the sticky box with the contract progress and sign/share buttons	Sign digitally	Digital unterschreiben	Body (text)		FALSE	FALSE			
I18N.SYI_02.Seller	Contract Fields Section	Header for the seller section	Seller	Verkäufer	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.sellerHeader1	Contract Fields Section	Subheader for person and address in the seller section	Name and Address	Person und Anschrift	Header (text)		FALSE	FALSE			
I18N.COMMON.Salutation	Contract Fields Section	Title for the seller	Title	Anrede	Personal data field	Herr	FALSE	FALSE	Select	Re-use options from listing flow	
I18N.COMMON.Please select	Contract Fields Section	Placeholder for title of the seller field	Please select	Bitte wählen	Placeholder		FALSE	FALSE			
I18N.REGISTRATION.First Name	Contract Fields Section	First name of the seller	First name	Vorname	Personal data field	John	TRUE	FALSE	Text field		
I18N.DIGITALCONTRACT.sellerFirstNamePlaceholder	Contract Fields Section	Placeholder for First name of the seller field	e.g., John	z.B. Max	Placeholder		FALSE	FALSE			
I18N.REGISTRATION.Last Name	Contract Fields Section	Last name of the seller	Last name	Nachname	Personal data field	Doe	TRUE	FALSE	Text field		
I18N.DIGITALCONTRACT.sellerLastNamePlaceholder	Contract Fields Section	Placeholder for last name of the seller field	e.g., Doe	z.B. Mustermann	Placeholder		FALSE	FALSE			
I18N.REGISTRATION.Street	Contract Fields Section	Street of the seller address	Street	Straße	Personal data field	Kastanienallee 	TRUE	FALSE	Text field		
I18N.DIGITALCONTRACT.sellerStreetPlaceholder	Contract Fields Section	Placeholder Street of the seller address	e.g., Main street	z.B. Musterstaße	Placeholder		FALSE	FALSE			
I18N.REGISTRATION.No.	Contract Fields Section	Street Number of the seller address	No.	Nr.	Personal data field	12	TRUE	FALSE	Text field		
I18N.DIGITALCONTRACT.sellerStreetNumberPlaceholder	Contract Fields Section	Placeholder Street Number of the seller address	e.g., 12a	z.B. 12a	Placeholder		FALSE	FALSE			
I18N.REGISTRATION.Zip Code	Contract Fields Section	zip code of the seller address	Postal code	PLZ	Personal data field	71612	TRUE	FALSE	Text field	ZIP validation (difficult to do, as it changes based on countries). If something is already available, reuse otherwise skip)	
I18N.DIGITALCONTRACT.sellerZipPlaceholder	Contract Fields Section	Placeholder zip code of the seller address	e.g., 12103	z.B. 12103	Placeholder		FALSE	FALSE			
I18N.SEARCH.City	Contract Fields Section	city of the seller address	City	Stadt	Personal data field	Berlin	TRUE	FALSE	Text field		
I18N.DIGITALCONTRACT.sellerPlaceholder	Contract Fields Section	Placeholder city of the seller address	e.g., Berlin	z.B. Berlin	Placeholder		FALSE	FALSE			
I18N.REGISTRATION.Country	Contract Fields Section	country of the seller address	Country	Land	Personal data field	Germany	TRUE	FALSE	Select	Dropdown with country list	
I18N.DIGITALCONTRACT.sellerCountryPlaceholder	Contract Fields Section	Placeholder country of the seller address	e.g., Germany	z.B. Germany	Placeholder		FALSE	FALSE			
I18N.COMMON.Contact_Data	Contract Fields Section	Subheader for contact data	Contact data	Kontaktdaten	Header (text)		FALSE	FALSE			
I18N.COMMON.Email	Contract Fields Section	Email of the seller (must come from mobile.de profile and must always be locked)	Email	E-Mail	Personal data field	john.doe@adevinta.com	TRUE	FALSE	Text field	must always be locked	
I18N.DIGITALCONTRACT.sellerEmailPlaceholder	Contract Fields Section	Placeholder Email of the seller (must come from mobile.de profile and must always be locked)	e.g., john.doe@mail.com	z.B. max.mustermann@mail.de	Placeholder		FALSE	FALSE			
I18N.REGISTRATION.Country code	Contract Fields Section	country code of the sellers phone number	Country code	Ländervorwahl	Personal data field	(+49)	TRUE	FALSE	Select	Re-use options from listing flow	
I18N.DIGITALCONTRACT.sellerCountryCodePrefill	Contract Fields Section	Prefill country code of the sellers phone number	*+49* (DE)	*+49* (DE)	Prefill		FALSE	FALSE			
I18N.REGISTRATION.Mobile Phone	Contract Fields Section	phone of the seller	Mobile number	Mobiltelefon	Personal data field	123456789	TRUE	FALSE	Text field/ Phone number	Phone number validation (E.164 international format)	
I18N.DIGITALCONTRACT.sellerPhonePlaceholder	Contract Fields Section	Placeholder phone of the seller	Enter phone number	Telefonnummer eingeben	Placeholder		FALSE	FALSE			
I18N.HOMEPAGE.Personal_Data	Contract Fields Section	Subheader for personal data	1.3 Personal information	Persönliche Angaben	Header (text)		FALSE	FALSE			
I18N.COMMON.Date_Of_Birth	Contract Fields Section	Date of Birth of the seller	Date of birth	Geburtsdatum	Personal data field	12.05.1990	TRUE	FALSE	Date field	18+ validation (user needs to be at least 18 years)	
I18N.DIGITALCONTRACT.sellerDateOfBirthPlaceholder	Contract Fields Section	Placeholder date of birth of the seller	DD.MM.YYYY	TT.MM.JJJJ	Placeholder			FALSE			
I18N.DIGITALCONTRACT.sellerIdentityDocumentNumber	Contract Fields Section	passport or ID number of the seller	ID / Passport number	Personalausweis- bzw. Pass-Nr.	Personal data field	F7KAS78	?	FALSE	Text field		
I18N.DIGITALCONTRACT.sellerIdentityDocumentNumberPlaceholder	Contract Fields Section	Placeholder passport or ID number of the seller	e.g., F7KAS78	z.B. F7KAS78	Placeholder		FALSE	FALSE			
digitalContract.sellerIdentityDocumentIssuer	Contract Fields Section	issuer of the passport or ID number of the seller	Issuing authority	Ausstellende Behörde	Personal data field	Bezirksamt Charlottenburg	FALSE	FALSE	Text field		
digitalContract.sellerIdentityDocumentDateOfIssuance	Contract Fields Section	date of issuance of the passport or ID number of the seller	Date of issuance	Datum der Ausstellung	Personal data field	20.12.2025	FALSE	FALSE	Date field		
I18N.COMMON.Vehicle	Contract Fields Section	Header for the vehicle section	Vehicle	Fahrzeug	Header (text)		FALSE	FALSE			
I18N.SYI.Vehicle_Data	Contract Fields Section	Subheader for vehicle section	Vehicle data	Fahrzeugdaten	Header (text)		FALSE	FALSE			
I18N.COMMON.Brand	Contract Fields Section	The make of the car	Make	Marke	Contract data field	Audi	TRUE	FALSE	Select	Re-use options from listing flow	
I18N.COMMON.Please select	Contract Fields Section	Placeholder of make of the car	Please select	Bitte wählen			FALSE	FALSE			
I18N.VEHICLE.Model	Contract Fields Section	The model of the car	Model	Modell	Contract data field	A6	TRUE	FALSE	Select	Re-use options from listing flow	
I18N.COMMON.Please select	Contract Fields Section		Please select	Bitte wählen			FALSE	FALSE			
I18N.COMMON.First Registration Date	Contract Fields Section	Month of the first registration of the vehicle	First registration	Erstzulassung	Contract data field	May	TRUE	FALSE	Select	Re-use options from listing flow	
I18N.DIGITALCONTRACT.firstRegistrationYear	Contract Fields Section	Year of the first registration of the vehicle			Contract data field	2014	TRUE	FALSE	Select	Re-use options from listing flow	
I18N.COMMON.Month	Contract Fields Section	Placeholder Month of the first registration of the vehicle	Month	Monat			FALSE	FALSE			
I18N.COMMON.Year	Contract Fields Section	Placeholder Year of the first registration of the vehicle	Year	Jahr			FALSE	FALSE			
I18N.DIGITALCONTRACT.fuelType	Contract Fields Section	motorization of the vehicle	Motorization	Motorisierung (Kraftstoffart) 	Contract data field	Diesel	FALSE	FALSE	Select	Re-use options from listing flow	
I18N.COMMON.Please select			Please select	Bitte wählen			FALSE	FALSE			
I18N.VEHICLE.Power	Contract Fields Section	Horse power of the car	Horse Power	Leistung	Contract data field	100	FALSE	FALSE	Text field		
I18N.DIGITALCONTRACT.horsePowerUnit	Contract Fields Section	Unit for the horse power of the car			Contract data field	PS	FALSE	FALSE	Select	Re-use options from listing flow	
I18N.DIGITALCONTRACT.horsePowerPlaceholder	Contract Fields Section	Placeholder of Horse power of the car	e.g., 77 kW or 105 PS	z.b. 77 kW oder 105 PS	Placeholder		FALSE	FALSE			
I18N.VEHICLE.PS	Contract Fields Section	Prefill of Unit for the horse power of the car	PS	PS	Prefill		FALSE	FALSE			
I18N.COMMON.Vehicle_Details	Contract Fields Section	Subheader car details for the vehicle section	Vehicle details	Fahrzeugdetails	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.nextInspectionMonth	Contract Fields Section	Month of the next main inspection (HU)	Main inspection ("TÜV") valid until	HU ("TÜV") gültig bis	Contract data field	May	TRUE	FALSE	Select	Re-use options from listing flow	
I18N.DIGITALCONTRACT.nextInspectionYear	Contract Fields Section	Year of the next main inspection (HU)			Contract data field	2026	TRUE	FALSE	Select	Re-use options from listing flow	
			Month	Monat			FALSE	FALSE			
			Jahr	Year			FALSE	FALSE			
I18N.VEHICLE.Registration_Number	Contract Fields Section	Number of the license plate of the current owner	License Plate	Amtliches Kennzeichen	Contract data field	LB ES 9712	FALSE	FALSE	Text field		
I18N.DIGITALCONTRACT.licensePlatePlaceholder	Contract Fields Section	Placeholder number of the license plate of the current owner	B - LN 1234	B - LN 1234	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.vin	Contract Fields Section	VIN number of the vehicle	VIN	Fahrzeug-Identifikationsnummer (FIN)	Contract data field	WBA5A51000N123456	TRUE	FALSE	Text field	Validation if possible, ISO 3779	
I18N.DIGITALCONTRACT.vinPlaceholder	Contract Fields Section	Placeholder VIN number of the vehicle	e.g., WVWZZZ1JZ2W057177	z.B. WVWZZZ1JZ2W057177	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.vehicleRegistrationCertificateNumber2	Contract Fields Section	Document Number (Nummer der Zulassungsbescheinigung)	Vehicle Registration Certificate Number (Part II)	Nummer Fahrzeugbrief (Zulassungsbescheinigung Teil II)	Contract data field	EJ120000	TRUE	FALSE	Text field		
I18N.DIGITALCONTRACT.vehicleRegistrationCertificateNumber2Placeholder	Contract Fields Section	Placeholder Document Number (Nummer der Zulassungsbescheinigung)	e.g., WBA12345678910117	z.b. WBA12345678910117	Placeholder		FALSE	FALSE			
I18N.VEHICLE.Vehicle Description	Contract Fields Section	Description of vehicle including damages, usually prefilled from ad listing description	Vehicle description	Fahrzeugbeschreibung	Contract data field	Black van, some minor scratches on left front door...	FALSE	FALSE	Text area		
I18N.DIGITALCONTRACT.vehicleDescriptionPlaceholder	Contract Fields Section	Placeholder Description of vehicle including damages, usually prefilled from ad listing description	e.g., damage, accident damage, etc.	z.B. Beschädigungen, Unfallschäden etc.	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.vehicleHeader3	Contract Fields Section	Subheader about documents and images	Vehicle documents and images	Fahrzeugdokumente und Bilder	Header (text)			FALSE			
I18N.DIGITALCONTRACT.attachmentsBody1	Contract Fields Section	Body 1 for the attachment section	Upload images and documents	Bilder und Dokumente hochladen	Body (text)			FALSE			
I18N.SYI.Add_Via_Drag_Drop	Contract Fields Section	Body 2 for the attachment section	...or add them via Drag & Drop	...oder per Drag & Drop hinzufügen	Body (text)			FALSE			
I18N.DIGITALCONTRACT.attachmentsButton	Contract Fields Section	Button in the attachment section	Select Files	Dateien auswählen	Button			FALSE			
I18N.DIGITALCONTRACT.attachmentsBody3	Contract Fields Section	Body 3 for attachment section	Relevant vehicle documents and images, such as vehicle registration documents, inspection reports, or photos of damage. (PDF, JPG, or PNG—maximum 10 MB per file)	Relevante Fahrzeugdokumente und Bilder, z.B. Fahrzeugpapiere, HU-Bericht oder Schadensfotos. (PDF, JPG oder PNG - maximal 10 MB pro Datei)	Body (text)			FALSE			
I18N.DIGITALCONTRACT.vehicleHeader4	Contract Fields Section	Subheader for vehicle section, equipment	Equipment and accessories	Zubehör und Zusatzausstattung	Header (text)			FALSE			
I18N.DIGITALCONTRACT.equipment	Contract Fields Section	List of any equipment that comes with the car	The vehicle is sold with the following additional equipment and accessories	Das Fahrzeug wird inklusive folgender Zusatzausstattung bzw. Zubehör verkauft	Contract data field	Roof box included	FALSE	FALSE	Text area		
I18N.DIGITALCONTRACT.equipmentPlaceholder	Contract Fields Section	Placeholder List of any equipment that comes with the car	e.g., roof rack, winter tires, etc.	z.B. Dachgepäckträger, Winterreifen etc.	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.sellersAssurancesHeader	Contract Fields Section	Header for the sellers assurances section	Sellers assurances	Zusicherungen des Verkäufers	Header (text)			FALSE			
I18N.DIGITALCONTRACT.sellersAssurancesBody1	Contract Fields Section	text that states sellers assurances	The Seller assures that the vehicle, including the accessories listed below, is his sole property.	Der Verkäufer versichert, dass das Fahrzeug einschließlich des unten genannten Zubehörs sein alleiniges Eigentum ist.	Body (text)			FALSE			
I18N.DIGITALCONTRACT.sellersAssurancesBody2	Contract Fields Section	Text that states additional seller assurances	Furthermore, the seller assures the following:	Des Weiteren versichert der Verkäufer Folgendes:	Body (text)			FALSE			
I18N.DIGITALCONTRACT.mileage	Contract Fields Section	The total mileage of the vehicle	Total mileage	Gesamtfahrleistung des Fahrzeugs	Contract data field	10.000 km	TRUE	FALSE	Number field	This field needs to have a unit included (km)	
I18N.DIGITALCONTRACT.mileagePlaceholder	Contract Fields Section	Plcaeholder for The total mileage of the vehicle	e.g., 78.500	z. B. 78.500	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.originalEngine	Contract Fields Section	Whether the vehicle has the original engine	The vehicle is equipped with the original engine	Das Fahrzeug ist mit dem Originalmotor ausgerüstet	Contract data field	FALSE	FALSE	FALSE	Toggle button 	Yes/No	
I18N.DIGITALCONTRACT.replacementEngine	Contract Fields Section	Whether the vehicle has a replacement engine	The vehicle is equipped with a replacement engine	Das Fahrzeug ist mit einem Austauschmotor ausgerüstet	Contract data field		FALSE	FALSE	Toggle button 	Yes/No Show if originalEngine = No	
I18N.DIGITALCONTRACT.replacementEngineMileage	Contract Fields Section	The mileage of the replacement engine	Mileage of the replacement engine	Kilometerstand des Austauschmotors	Contract data field	10.000 km	FALSE	FALSE	Text field	Show if replacementEngine = Yes	
I18N.DIGITALCONTRACT.replacementEngineMileagePlaceholder	Contract Fields Section	Plcaeholder for The mileage of the replacement engine	e.g., 78.500	z.B. 78.500	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.hasAccidentHistoryCurrentOwner	Contract Fields Section	Whether the car has been in an accident with current owner	The vehicle has been in an accident since it became the seller's property	Das Fahrzeug hatte, seit es im Eigentum des Verkäufers steht, einen Unfall	Contract data field	Yes	TRUE	FALSE	Toggle button 	Yes/No	
I18N.DIGITALCONTRACT.accidentDescriptionCurrentOwner	Contract Fields Section	Decription of accident and damages on the car of current Owner	Description of damages	Beschreibung der Schäden	Contract data field	The car has hit a lamp post and the front lights were exchanged by a certified mechanic. The receipt is attached. 	FALSE	FALSE	Text area	Show if hasAccidentHistoryCurrentOwner = Yes	
I18N.DIGITALCONTRACT.accidentDescriptionCurrentOwnerPlaceholder	Contract Fields Section	Placeholder Decription of accident and damages on the car of current Owner	e.g., scratches and dents	z.B. Kratzer und Dellen	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.hasAccidentHistoryPreviousOwner	Contract Fields Section	Whether the car has been in an accident with previous owner	As far as is known, the vehicle was involved in an accident during the rest of that time	Soweit bekannt, hatte das Fahrzeug in der übrigen Zeit einen Unfall	Contract data field	Yes	TRUE	FALSE	Toggle button	Yes/No	
I18N.DIGITALCONTRACT.accidentDescriptionPreviousOwner	Contract Fields Section	Decription of accident and damages on the car of Previous Owner	Description of damages	Beschreibung der Schäden	Contract data field	The car has hit a lamp post and the front lights were exchanged by a certified mechanic. The receipt is attached. 	FALSE	FALSE	Text area	Show if hasAccidentHistoryPreviousOwner = Yes	
I18N.DIGITALCONTRACT.accidentDescriptionPreviousOwnerPlaceholder	Contract Fields Section	Placeholder Description of accident and damages on the car of Previous Owner	e.g., scratches and dents	z.B. Kratzer und Dellen	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.sellersDeclarationHeader	Contract Fields Section	Header for the seller's declarations	Seller's declarations	Erklärungen des Verkäufers	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.previousOwners	Contract Fields Section	The number of previous owners	Number of previous owners (inlcluding seller)	Anzahl der Vorbesitzer (einschl. Verkäufer)	Contract data field	2	FALSE	FALSE	Select		
I18N.DIGITALCONTRACT.commerciallyUsed	Contract Fields Section	Whether the vehicle was commercially used	The vehicle was used for commercial purposes, such as a taxi, rental car, or driving school car	Das Fahrzeug wurde gewerblich genutzt, z.B. als Taxi, Miet- oder Fahrschulwagen	Contract data field	No	FALSE	FALSE	Toggle button	Yes/No	
I18N.DIGITALCONTRACT.import	Contract Fields Section	Whether the vehicle was imported	The vehicle is an imported vehicle.	Bei dem Fahrzeug handelt es sich um ein Importfahrzeug	Contract data field	Yes	FALSE	FALSE	Toggle button	Yes/No	
I18N.DIGITALCONTRACT.warrantiesHeader	Contract Fields Section	Header of warranties section	Exclusion of Liability for Material Defects	Ausschluss der Sachmängelhaftung	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.warrantiesBody	Contract Fields Section	Descriptive text about warranteis (e.g. bought as seen)	The vehicle is sold as inspected and with exclusion of liability for material defects, unless a specific warranty is given under Clause 3. This exclusion does not apply to claims for damages arising from liability for material defects that are based on intentional or grossly negligent breach of duty by the seller, nor in cases of culpable injury to life, body or health. To the extent that claims for liability for material defects exist against third parties, these are hereby assigned to the buyer.	Das Fahrzeug wird wie besichtigt und unter Ausschluss der Sachmängelhaftung verkauft, soweit nicht unter Ziffer 3. eine bestimmte Zusicherung erfolgt. Dieser Ausschluss gilt nicht für Schadensersatzansprüche aus Sachmängelhaftung, die auf einer vorsätzlichen oder grob fahrlässigen Verletzung von Pflichten des Verkäufers beruhen sowie bei der schuldhaften Verletzung von Leben, Körper und Gesundheit. Soweit Ansprüche aus Sachmängelhaftung gegen Dritte bestehen, werden sie an den Käufer abgetreten.	Body (text)		FALSE	FALSE			
I18N.COMMON.Buyer	Contract Fields Section	Header of the buyer section	Buyer	Käufer	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.buyerInfoBoxHeader	Contract Fields Section	Header in infobox in the buyer section	Buyer information not yet available? 	Käuferdaten noch nicht bekannt? 	Body (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.buyerInfoBoxBody	Contract Fields Section	Body in infobox in the buyer section	Send the contract to the buyer via email or text message. The buyer can then fill in the missing information. 	Sende den Vertrag per E-Mail oder SMS an den Käufer. Dieser kann die fehlenden Angaben anschließend ergänzen. 	Body (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.buyerInfoBoxBodyLink		Link in Body in infobox in the buyer section	Send contract to buyer	Vertrag an Käufer senden	Other		FALSE	FALSE			
I18N.DIGITALCONTRACT.buyerHeader 1	Contract Fields Section	Subheader in buyer section: Name and address	Name and Address	Person und Anschrift	Header (text)		FALSE	FALSE			
I18N.COMMON.Salutation	Contract Fields Section	Title for the buyer	Title	Anrede	Personal data field	Herr	FALSE	FALSE	Select	Re-use options from listing flow	
I18N.COMMON.Please select	Contract Fields Section	Placeholder Title for the buyer	Please select	Bitte wählen	Placeholder		FALSE	FALSE			
I18N.REGISTRATION.First Name	Contract Fields Section	First name of the buyer	First name	Vorname	Personal data field	Jane	TRUE	FALSE	Text field		
I18N.DIGITALCONTRACT.buyerFirstNamePlaceholder	Contract Fields Section	Placeholder First name of the buyer	e.g., Jane	z.B. Erika	Placeholder		FALSE	FALSE			
I18N.REGISTRATION.Last Name	Contract Fields Section	Last name of the buyer	Last name	Nachname	Personal data field	Doanne	TRUE	FALSE	Text field		
I18N.DIGITALCONTRACT.buyerLastNamePlaceholder	Contract Fields Section	Placeholder Last name of the buyer	e.g., Doe	z.B. Mustermann	Placeholder		FALSE	FALSE			
I18N.REGISTRATION.Street	Contract Fields Section	Street of the buyer address	Street	Straße	Personal data field	Unter den Linden	TRUE	FALSE	Text field		
I18N.DIGITALCONTRACT.buyerStreetNumberPlaceholder	Contract Fields Section	Placeholder Street of the buyer address	e.g., Main street	z.B. Musterstaße	Placeholder		FALSE	FALSE			
I18N.REGISTRATION.No.	Contract Fields Section	house number of the buyer address	No.	Nr.	Personal data field	1	TRUE	FALSE	Text field		
I18N.DIGITALCONTRACT.buyerStreetNumberPlaceholder	Contract Fields Section	Placeholder house number of the buyer address	e.g., 12a	z.B. 12a	Placeholder		FALSE	FALSE			
I18N.REGISTRATION.Zip Code	Contract Fields Section	zip code of the buyer address	Zip	PLZ	Personal data field	12345	TRUE	FALSE	Text field	ZIP validation (difficult to do, as it changes based on countries). If something is already available, reuse otherwise skip)	
I18N.DIGITALCONTRACT.buyerZipPlaceholder	Contract Fields Section	Placeholder zip code of the buyer address	e.g., 12103	z.B. 12103	Placeholder		FALSE	FALSE			
I18N.SEARCH.City	Contract Fields Section	city of the buyer address	City	Stadt	Personal data field	Berlin	TRUE	FALSE	Text field		
I18N.DIGITALCONTRACT.buyerCityPlaceholder	Contract Fields Section	Placeholder city of the buyer address	e.g., Berlin	z.B. Berlin	Placeholder		FALSE	FALSE			
I18N.REGISTRATION.Country	Contract Fields Section	country of the buyer address	Country	Land	Personal data field	Germany	TRUE	FALSE	Select	Re-use options from listing flow	
I18N.DIGITALCONTRACT.buyerCountryPlaceholder	Contract Fields Section	Placeholder country of the buyer address	e.g., Germany	z.B. Germany	Placeholder		FALSE	FALSE			
I18N.COMMON.Contact_Data	Contract Fields Section	Subheader in buyer section: Contact data	Contact data	Kontaktdaten	Header (text)		FALSE	FALSE			
I18N.COMMON.Email	Contract Fields Section	Email of the buyer (come from mobile.de profile if available)	Email	E-Mail	Personal data field		TRUE	FALSE	Text field		
I18N.DIGITALCONTRACT.buyerEmailPlaceholder	Contract Fields Section	Placeholder Email of the buyer (come from mobile.de profile if available)	e.g., jane.doe@mail.com	z.B. erika.mustermann@mail.de	Placeholder		FALSE	FALSE			
I18N.REGISTRATION.Country code	Contract Fields Section	the country code of the buyers phone number	Country code	Ländervorwahl	Personal data field	(+49)	TRUE	FALSE	Select	Re-use options from listing flow	
I18N.DIGITALCONTRACT.buyerCountryCodePrefill	Contract Fields Section	Prefill of the country code of the buyers phone number	*+49* (DE)	*+49* (DE)	Prefill		FALSE	FALSE			
I18N.REGISTRATION.Mobile Phone	Contract Fields Section	phone of the buyer	Mobile number	Mobiltelefon	Personal data field	987654321	TRUE	FALSE	Phone number	Phone number validation (E.164 international format)	
I18N.DIGITALCONTRACT.buyerPhonePlaceholder	Contract Fields Section	Placeholder phone of the buyer	Enter phone number	Telefonnummer eingeben	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.buyerHeader2	Contract Fields Section	Subheader in buyer section: Personal information	Personal information	Persönliche Angaben	Header (text)		FALSE	FALSE			
I18N.COMMON.Date_Of_Birth	Contract Fields Section	Date of Birth of the buyer	Date of birth	Geburtsdatum	Personal data field	16.12.2000	TRUE	FALSE	Date field	18+ validation (user needs to be at least 18 years)	
I18N.DIGITALCONTRACT.buyerDateOfBirthPlaceholder	Contract Fields Section	Placeholder Date of Birth of the buyer	DD.MM.YYYY	TT.MM.JJJJ	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.buyerIdentityDocumentNumber	Contract Fields Section	passport or ID number of the buyer	ID / Passport number	Personalausweis- bzw. Pass-Nr.	Personal data field	7687JHK	?	FALSE	Text field		
I18N.DIGITALCONTRACT.buyerIdentityDocumentNumberPlaceholder	Contract Fields Section	Placeholder passport or ID number of the buyer	e.g., F7KAS78	z.B. F7KAS78	Placeholder			FALSE			
digitalContract.buyerIdentityDocumentIssuer	Contract Fields Section	issuer of the passport or ID number of the buyer	Issuing authority	Ausstellende Behörde	Personal data field	Buergerburo Ludwigsburg	FALSE	FALSE	Text field		
digitalContract.buyerIdentityDocumentDateOfIssuance	Contract Fields Section	date of issuance of the passport or ID number of the buyer	Date of issuance	Datum der Ausstellung	Personal data field	12.08.2019	FALSE	FALSE	Date field		
I18N.DIGITALCONTRACT.handoverHeader	Contract Fields Section	Header for the handover section	Handover	Übergabe	Header (text)		FALSE	FALSE			
I18N.VEHICLE.Test_Drive	Contract Fields Section	Subheader for the handover section: Test drive	Test drive	Probefahrt	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.testDrive	Contract Fields Section	Whether the buyer conducted a test drive or not	The buyer has conducted a test drive	Der Käufer hat eine Probefahrt durchgeführt	Contract data field	Yes	FALSE	FALSE	Toggle button	Yes/No	
I18N.DIGITALCONTRACT.testDriveDate	Contract Fields Section	The date the buyer conducted a test drive	Test drive date	Datum der Probefahrt	Contract data field	20.12.2026	FALSE	FALSE	Date field	Show if testDrive = Yes	
I18N.DIGITALCONTRACT.testDriveDatePlaceholder	Contract Fields Section	Placeholder of The date the buyer conducted a test drive	DD.MM.YYYY	TT.MM.JJJJ	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.documentsHeader	Contract Fields Section	Header for the vehicle documents section	Vehicle documents	Fahrzeugdokumente	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.documentsBody	Contract Fields Section	Body for the vehicle documents section	The buyer received the following documents/items on the date listed below:	Der Käufer hat die folgenden Dokumente/Gegenstände am unten angegebenen Datum erhalten: 	Body (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.vehicleRegistrationCertificatePart1	Contract Fields Section	Whether the buyer received the vehicle registration certificate part 1 (Zulassungsbescheinigung Teil I or Fahrzeugschein)	Vehicle registration certificate part 1	Zulassungsbescheinigung 1 (Fahrzeugschein)	Contract data field		FALSE	FALSE	Checkbox		
I18N.DIGITALCONTRACT.vehicleRegistrationCertificatePart2	Contract Fields Section	Whether the buyer received the vehicle registration certificate part 2(Zulassungsbescheinigung Teil 2 or Fahrzeugbrief)	Vehicle registration certificate part 2	Zulassungsbescheinigung 2 (Fahrzeugbrief)	Contract data field		FALSE	FALSE	Checkbox		
I18N.DIGITALCONTRACT.decommisiongCertificate	Contract Fields Section	Whether the buyer received the decomissioning certificate	Decomissioning certificate	Stillegungsbescheinigung	Contract data field		FALSE	FALSE	Checkbox		
I18N.DIGITALCONTRACT.vehicleInspectionCertificate	Contract Fields Section	Whether the buyer received the certificate of the last vehicle inspection (Hauptuntersuchung)	Certificate of the last main vehicle Inspection	Bescheinigung über die letzte Hauptuntersuchung	Contract data field		FALSE	FALSE	Checkbox		
I18N.DIGITALCONTRACT.serviceBook	Contract Fields Section	Whether the buyer received the service book	Service book	Serviceheft	Contract data field		FALSE		Checkbox		
I18N.DIGITALCONTRACT.vehicleInspectionReports	Contract Fields Section	Inspection reports by external parties such as ADAC	Vehicle inspection reports (e.g., TÜV, DEKRA, ADAC)	Fahrzeug-Gutachen (z.B. TÜV, DEKRA, ADAC)	Contract data field		FALSE	FALSE			
I18N.DIGITALCONTRACT.keys	Contract Fields Section	Number of keys for the vehicle	Number of keys	Anzahl der Schlüssel	Contract data field	2	FALSE	FALSE	Toggle button: 1,2,3,Mehr		
I18N.DIGITALCONTRACT.keysMore	Contract Fields Section	If there are more than 3 keys			Contract data field		FALSE	FALSE	Text field, 	show if I18N.DIGITALCONTRACT.keys = "Mehr"	
I18N.DIGITALCONTRACT.handoverHeader2	Contract Fields Section	Suberheader for the handover section: Handover agreements	Handover agreements	Vereinbarungen zur Übergabe	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.reregistered	Contract Fields Section	If the buyer re-registers the car after the handover	The buyer agrees to re-register the vehicle immediately, but no later than one week after delivery.	Der Käufer verpflichtet sich, das Fahrzeug unverzüglich, jedoch spätestens innerhalb einer Woche nach Übergabe umzumelden	Contract data field		FALSE	FALSE	Radio button TRUE/FALSE		
I18N.DIGITALCONTRACT.reregisteredInformation	Contract Fields Section	Content with additional info regarding this registration process			Body (text)	The buyer undertakes to reregister the car within 4 days...	FALSE	FALSE		Show if I18N.DIGITALCONTRACT.reregistered is TRUE	
I18N.DIGITALCONTRACT.deregistered	Contract Fields Section	Whether the seller de-registers the car before the handover	The vehicle will be handed over with its registration canceled upon completion of the purchase agreement.	Das Fahrzeug wird nach Abschluss des Kaufvertrags abgemeldet übergeben	Contract data field		FALSE	FALSE	Radio button TRUE/FALSE		
I18N.DIGITALCONTRACT.deregisteredInformation	Contract Fields Section	Content with additional info regarding this registration process			Body (text)	The seller deregisters with the zulassungstelle etc.	FALSE	FALSE		Show if I18N.DIGITALCONTRACT.deregistered is TRUE	
I18N.DIGITALCONTRACT.otherAgreementsHandover	Contract Fields Section	If buyer and seller agree on another handover process	Other agreements 	Weitere Vereinbarungen	Contract data field		FALSE	FALSE	Radio button TRUE/FALSE		
I18N.DIGITALCONTRACT.otherAgreementsHandoverDescription	Contract Fields Section	Textbox where users can add additional info on registration	The following additional agreement was reached regarding the handover:	Folgende weitere Vereinbarungen wurden bezüglich der Übergabe getroffen:	Contract data field	buyer and seller re-register together	FALSE	FALSE	Text area	Show If otherAgreementsHandover is true	
I18N.DIGITALCONTRACT.otherAgreementsHandoverDescriptionPlaceholder	Contract Fields Section	Placehlder forTextbox where users can add additional info on registration	Please enter here...	Bitte hier eingeben...	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.handoverDate	Contract Fields Section	The date for the planned handover of the car	Handover date	Datum der Übergabe	Contract data field		TRUE	FALSE	Date field		
I18N.DIGITALCONTRACT.handoverDate	Contract Fields Section	Placeholder for the date for the planned handover of the car	DD.MM.YYYY	TT.MM.JJJJ	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.soleOwnerHeader	Contract Fields Section	Header for the sole owner declaration	Retention of title	Eigentumsvorbehalt	Header (text)			FALSE			
I18N.DIGITALCONTRACT.soleOwnerBody	Contract Fields Section	Body for the sole owner declaration 	The vehicle remains the property of the seller until the purchase price has been paid in full.	Das Fahrzeug bleibt bis zur vollständigen Bezahlung des Kaufpreises im Eigentum des Verkäufers	Body (text)			FALSE			
I18N.DIGITALCONTRACT.priceHeader	Contract Fields Section	Header for the price and payment section	Price and payment	Kaufpreis und Zahlung	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.priceHeader1	Contract Fields Section	Subheader for the price section: Price and payment	Body for the sole owner declaration 	Kaufpreis und Zahlung	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.price	Contract Fields Section	Price of the vehicle	Total price incl. VAT	Gesamtpreis inkl. MwSt.	Contract data field	25.00€	TRUE	FALSE	Text field	This field needs to have a unit included (€)	
I18N.DIGITALCONTRACT.pricePlaceholder	Contract Fields Section	Placeholder for the price of the vehicle	12000	12000	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.downPayment	Contract Fields Section	The down payment that the buyer pays upfront for the car	Down Payment	Anzahlung	Contract data field	500€	FALSE	FALSE	Text field	This field needs to have a unit included (€)	
I18N.DIGITALCONTRACT.downPaymentPlaceholder	Contract Fields Section	Placeholder for The down payment that the buyer pays upfront for the car	2000	2000	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.specialAgreements	Contract Fields Section	Any special agreements in regards to the car purchase	Special agreements regarding the contract	Sondervereinbarungen zum Kaufvertrag	Contract data field	The buyer will receive a second set of tires	FALSE	FALSE	Text field		
I18N.DIGITALCONTRACT.specialAgreementsPlaceholder	Contract Fields Section	Placeholder for Any special agreements in regards to the car purchase	Please enter here...	Bitte hier eingeben...	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.paymentMethod	Contract Fields Section	The payment method used for the transaction	Payment method	Zahlungsart	Contract data field	Cash	TRUE	FALSE	"Select:
Cash
Bank transfer
Other"		
I18N.COMMON.Please select	Contract Fields Section	Placeholder for The payment method used for the transaction	Please select	Bitte wählen	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.paymentAgreements	Contract Fields Section	Other payment agreements	Other payment agreements	Andere Zahlungsvereinbarungen	Contract data field	The buyer will pay the 500€ to the sellers bank account before the handover date	FALSE	FALSE	Text field	Show if paymentMethod = Other	
I18N.DIGITALCONTRACT.paymentAgreementsPlaceholder	Contract Fields Section	Placeholder for Other payment agreements	Please enter here...	Bitte hier eingeben...	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.priceHeader2	Contract Fields Section	Subheader for the price section: Price and payment	Bank transfer	Banküberweisung	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.sellerIban	Contract Fields Section	The IBAN of the seller	Seller IBAN	IBAN des Verkäufers	Contract data field	DE12 1212 1212 1212 1212	FALSE	FALSE	Text field	Show if paymentMethod = bank transfer	
I18N.DIGITALCONTRACT.sellerIbanPlaceholder	Contract Fields Section	Placeholder for the IBAN of the seller	DE12 1212 1212 1212 1212	DE12 1212 1212 1212 1212	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.sellerAccountHolderName	Contract Fields Section	Account holder name for seller bank	Account holder name	Name des Kontoinhabers	Contract data field	Max Mustermann	FALSE	FALSE	Text field	Show if paymentMethod = bank transfer	
I18N.DIGITALCONTRACT.sellerAccountHolderNamePlaceholder	Contract Fields Section	Placeholder for the account holder name of the seller	Max Mustermann	Max Mustermann	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.softwareUpdates	Contract Fields Section	Whether the seller has carried out all software/recall updates	The seller declares that all mandatory recalls/software updates have been carried out.		Contract data field	Yes	FALSE	FALSE	Radio button	Yes/No	
I18N.DIGITALCONTRACT.remoteAppConnections	Contract Fields Section	Whether the seller has disconnected all remote app connection and that the seller no longer has any digital access to the car.	The seller declares that all remote app connections have been disconnected and there is no longer any digital access to the car		Contract data field	Yes	FALSE	FALSE	Radio button	Yes/No	
I18N.DIGITALCONTRACT.signingHeader	Signing Box Section	Header for the signing section	Signature	Unterzeichnung	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.signingBody1	Signing Box Section	Body1 for the signing section	When is the sales contract legally valid?	Wann ist der Kaufvertrag rechtsgültig? 	Body (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.signingBody2		Body2 for the signing section	Only if both parties—the buyer and the seller—have signed the contract.	Nur wenn beide Parteien, Käufer und Verkäufer, den Vertrag unterzeichnet haben.	Body (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.signingBoxStatusSeller	Signing Box Section	Status for seller in signing box	Depends on contract state tbd	Depends on contract state tbd	Status		FALSE	FALSE			
I18N.SYI_02.Seller	Signing Box Section	"Seller" in the signing box	Seller	Verkäufer	Body (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.signingBoxSellerName	Signing Box Section	Seller name in the signing box	[Seller Name]	[Seller Name]	Body (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.signingBoxSellerSignButton	Signing Box Section	Sign button for seller	Sign digitally	Digital unterzeichnen	Button		FALSE	FALSE			
I18N.DIGITALCONTRACT.signingBoxSellerRemindButton	Signing Box Section	Button in the seller box for the buyer to remind the seller to sign the contract	Send reminder	Erinnerung senden	Button		FALSE	FALSE			
I18N.DIGITALCONTRACT.signingBoxStatusBuyer	Signing Box Section	Status for Buyer in Signing box	Depends on contract state tbd	Depends on contract state tbd	Status		FALSE	FALSE			
I18N.COMMON.Buyer	Signing Box Section	"Buyer" in the signing box	Buyer	Käufer	Body (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.signingBoxBuyerName	Signing Box Section	Buyer name in the signing box	[Buyer Name], [Buyer email], [Buyer phone]	[Buyer Name], [Buyer email], [Buyer phone]	Body (text)		FALSE	FALSE		If name is available, name should displayed, otherwise first email and then phone number.	
I18N.DIGITALCONTRACT.signingBoxBuyerSignButton	Signing Box Section	Sign button for button	Sign digitally	Digital unterzeichnen	Button		FALSE	FALSE			
I18N.DIGITALCONTRACT.signingBoxBuyerResenInvitationButton	Signing Box Section	Button in the buyer box for the seller to resend the invitation to the buyer	Resend the contract	Vertrag erneut senden	Button		FALSE	FALSE			
I18N.DIGITALCONTRACT.signingBoxBuyerRemindButton	Signing Box Section	Button in the buyer box for the sellre to remind the seller to sign the contract	Send reminder	Erinnerung senden	Button		FALSE	FALSE			
I18N.DIGITALCONTRACT.signingBoxHistoryLog	Signing Box Section	Text to show the change log	View Change History [NUMBER OF CHANGES]	Änderungshistorie anzeigen [NUMBER OF CHANGES]	Body (text)		FALSE	FALSE		Should open the change history log	
I18N.DIGITALCONTRACT.actionShareContractHeader	Action Modals	Header of the share contract action modal	Send contract to the buyer	Vertrag an Käufer senden	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.actionShareContractBody	Action Modals	Body of the share contract action modal			Body (text)		FALSE	FALSE			
I18N.COMMON.Email	Action Modals	Tab to choose in which way to send the contract	Email	E-Mail	Other		FALSE	FALSE			
I18N.COMMON.SMS	Action Modals	Tab to choose in which way to send the contract	SMS	SMS	Other		FALSE	FALSE			
I18N.DIGITALCONTRACT.actionShareContractEmail	Action Modals	Email field for the sharing action	Email address	E-Mail-Adresse	Other field		FALSE	TRUE			
I18N.DIGITALCONTRACT.actionShareContractEmailPlaceholder	Action Modals	Placeholder for Email field for the sharing action	e.g., john.doe@mail.com	z.B. max.mustermann@mail.de	Placeholder		FALSE	FALSE			
I18N.REGISTRATION.Country code	Action Modals	Country code field for sms sharing	Country code	Ländervorwahl	Other field		FALSE	TRUE			
I18N.DIGITALCONTRACT.actionShareContractSmsCountryCodePrefill	Action Modals	Prefill for country code for sms sharing	*+49* (DE)	*+49* (DE)	Prefill		FALSE	FALSE			
I18N.REGISTRATION.Mobile Phone	Action Modals	Mobile number field for sms sharing	Mobile number	Mobiltelefon	Other field		FALSE	TRUE			
I18N.DIGITALCONTRACT.actionShareContractSmsPhoneNumberPlcaeholder	Action Modals	Placeholder for Mobile number for sms sharing	Enter phone number	Telefonnummer eingeben	Placeholder		FALSE	FALSE			
I18N.DIGITALCONTRACT.actionShareContractButton	Action Modals	Share contract button in action modal	Send contract to the buyer	Vertrag an Käufer senden	Button		FALSE	FALSE			
I18N.DIGITALCONTRACT.actionChangelogHeader	Action Modals	 header in the change log action modal	Change history	Änderungshistorie	Header (text)		FALSE	FALSE			
I18N.SYI.Close	Action Modals	Button in the change log action modal	Close	Schließen	Button		FALSE	FALSE			
I18N.DIGITALCONTRACT.actionSignProcessStep1Header	Action Modals	Header in the Sign process step 1 action modal	Sign digitally	Digital unterschreiben	Header (text)		FALSE	FALSE			
I18N.DIGITALCONTRACT.actionSignProcessStep1Body1	Action Modals	Body 1 in the sign process step 1 action modal			Body (text)		FALSE	FALSE			
I18N.SYI.Legal note	Action Modals	Header of box in sign process step 1 action modal	Legal Notice	Rechtlicher Hinweis	Header (text)						
I18N.DIGITALCONTRACT.actionSignProcessStep1BoxBody	Action Modals	Body of box in sign process step 1 action modal	I confirm that I am the person named in the contract, that the information provided is correct, and that I wish to sign this version of the contract.	Ich bestätige, dass ich die in dem Vertrag genannte Person bin, dass die angegebenen Informationen korrekt sind und dass ich diese Fassung des Vertrags unterzeichnen möchte.	Body (text)						
I18N.DIGITALCONTRACT.actionSignProcessStep1Body2	Action Modals	Body 2 in the sign process step 1 action modal			Body (text)						
I18N.DIGITALCONTRACT.actionSignProcessStep1Button	Action Modals	Button in the sign process step 1 action modal	Continue to the signature	Weiter zur Unterschrift	Button						
I18N.COMMON.Cancel	Action Modals	Action in the sign process step 1 action modal	Cancel	Abbrechen	Action (button)						
I18N.DIGITALCONTRACT.actionSignProcessStep2Header	Action Modals	Header in the Sign process step 2 action modal	Sign digitally	Digital unterschreiben	Header (text)						
I18N.DIGITALCONTRACT.actionSignProcessStep2Body	Action Modals	Body in the Sign process step 2 action modal			Body (text)						
I18N.DIGITALCONTRACT.actionSignProcessStep2Field1	Action Modals	Field 1 in the Sign process step 2 action modal	Your first and last name	Dein Vor- und Nachname	Other field	Max Mustermann 					
I18N.DIGITALCONTRACT.actionSignProcessStep2Field2	Action Modals	Field 2 in the Sign process step 2 action modal	Preview Signature	Vorschau Unterschrift	Other						
I18N.DIGITALCONTRACT.actionSignProcessStep2Button	Action Modals	Button in the sign process step 2 action modal	Sign contract now	Vertrag jetzt unterschreiben	Button						
I18N.COMMON.Cancel	Action Modals	Action in the sign process step 2 action modal	Cancel	Abbrechen	Action (button)						
I18N.DIGITALCONTRACT.actionDeleteContractHeader	Action Modals	header in the delete contract action modal	Delete sales contract	Kaufvertrag löschen	Header (text)						
I18N.DIGITALCONTRACT.actionDeleteContractInfoBoxHeader	Action Modals	Infobox Header in the delete contract action modal	All contract data will be deleted	Alle Vertragsdaten werden gelöscht	Header (text)						
I18N.DIGITALCONTRACT.actionDeleteContractInfoBoxBody	Action Modals	Infobox Body in the delete contract action modal	When you delete the contract, you'll remove all information entered by you and the potential buyer. This action cannot be undone.	Mit dem Löschen entfernst du alle Eingaben von dir und dem potenziellen Käufer. Dieser Vorgang kann nicht rückgängig gemacht werden.	Body (text)						
I18N.DIGITALCONTRACT.actionDeleteContractBody	Action Modals	Body in the delet contract modal	You can create a new sales contract at any time later and send it to another potential buyer.	Du kannst später jederzeit einen neuen Kaufvertrag erstellen und an einen anderen potenziellen Käufer senden.	Body (text)						
I18N.DIGITALCONTRACT.actionDeleteContractButton	Action Modals	Button in the delete contract modal	Delete sales contract	Kaufvertrag löschen	Button						
I18N.COMMON.Cancel	Action Modals	Action in the delete contract modal	Cancel	Abbrechen	Action (button)						
I18N.DIGITALCONTRACT.actionRemoveCounterpartyHeader	Action Modals	Header in the remove counterparty modal	Remove [Buyer/Seller] from the contract?	[Käufer/Verkäufer] aus dem Vertrag entfernen?	Header (text)						
I18N.DIGITALCONTRACT.actionRemoveCounterpartyInfoBox	Action Modals	Infobox in the remove counterparty modal	When the [Buyer/Seller] is removed, all of the [Buyer/Seller]'s personal information, as well as the information entered by the [Buyer/Seller], including the signature (if any), will be removed from the contract.	Beim Entfernen des [Käufers/Verkäufers] werden alle persönlichen Daten des [Käufers/Verkäufers], sowie die vom [Käufer/Verkäufer] eingegebenen Daten, inklusive Unterschrift (falls vorhanden) aus dem Vertrag entfernt.	Body (text)						
I18N.DIGITALCONTRACT.actionRemoveCounterpartyBody1	Action Modals	Body 1 in the remove counterparty modal	You can then send the contract to a new [buyer/seller].	Anschließend kannst du den Vertrag an einen neuen [Käufer/Verkäufer]senden.	Body (text)						
I18N.DIGITALCONTRACT.actionRemoveCounterpartyBody2	Action Modals	Body 2 in the remove counterparty modal	All parties to the agreement must then sign the agreement again.	Alle Vertragsparteien müssen den Vertrag danach erneut unterschreiben. 	Body (text)						
I18N.DIGITALCONTRACT.actionRemoveCounterpartyButton	Action Modals	Button in the remove counterparty modal	Remove [Buyer/Seller]	[Käufer/Verkäufer] entfernen	Button						
I18N.COMMON.Cancel	Action Modals	Action  in the remove counterparty modal	Cancel	Abbrechen	Action (button)						
I18N.DIGITALCONTRACT.actionRemoveSignatureHeader	Action Modals	Header in the remove signature modal	Edit Contract Details	Vertragsdaten bearbeiten	Header (text)						
I18N.DIGITALCONTRACT.actionRemoveSignatureInfoBoxHeader	Action Modals	Header of infobox in remove signature modal	The contract has already been digitally signed by one of the parties	Der Vertrag wurde bereits von einer Vertragspartei digital unterschrieben	Header (text)						
I18N.DIGITALCONTRACT.actionRemoveSignatureInfoBoxBody	Action Modals	Body of infobox in remove signature modal	Changes to the contract details will remove all previous signatures.	Änderungen an den Vertragsdaten entfernen alle bisherigen Unterschriften.	Body (text)						
I18N.DIGITALCONTRACT.actionRemoveSignatureBody1	Action Modals	Body 1 in remove signature modal	"The changes will be documented in the change history. Your contract partner will be notified automatically.
"	"Die Änderungen werden in der Änderungshistorie dokumentiert. Dein Vertragspartner wird automatisch informiert.
"	Body (text)						
I18N.DIGITALCONTRACT.actionRemoveSignatureBody2	Action Modals	Body 2 in remove signature modal	Afterward, both parties must sign the contract again	Anschließend müssen beide Parteien den Vertrag erneut unterschreiben	Body (text)						
I18N.DIGITALCONTRACT.actionRemoveSignatureButton	Action Modals	Button in remove signature modal	Save changes	Änderungen speichern	Button						
I18N.COMMON.Cancel	Action Modals	Action in remove signature modal	Cancel	Abbrechen	Action (button)						
I18N.DIGITALCONTRACT.actionChangeLanguageHeader	Action Modals	Header in the change language modal	Change language	Sprache ändern	Header (text)						
I18N.DIGITALCONTRACT.actionRemoveSignatureInfoBoxHeader	Action Modals	Box header in the change language modal	The contract has already been digitally signed by one of the parties	Der Vertrag wurde bereits von einer Vertragspartei digital unterschrieben	Header (text)						
I18N.DIGITALCONTRACT.actionRemoveSignatureInfoBoxBody	Action Modals	Box Body in the change language modal	Changes to the contract will remove all previous signatures.	Änderungen am Vertrag entfernen alle bisherigen Unterschriften.	Body (text)						
I18N.DIGITALCONTRACT.actionChangeLanguageBody1	Action Modals	Body 1 in change language modal	Only you can change the language of the sales contract:	Nur du kannst die Sprache des Kaufvertrags ändern:	Body (text)						
I18N.DIGITALCONTRACT.actionChangeLanguageBody2	Action Modals	Body 2 in change language modal	German (Standard)	Deutsch (Standard)	Body (text)						
I18N.REGISTRATION.English	Action Modals	Body 3 in change language modal	English	Englisch	Body (text)						
I18N.DIGITALCONTRACT.actionChangeLanguageBody4	Action Modals	Body 4 in change language modal	The contract is displayed in the same language for both parties.	Der Vertrag wird immer für beide Parteien in derselben Sprache angezeigt.	Body (text)						
I18N.COMMON.Save	Action Modals	Button in change language modal	Save	Speichern	Button						
I18N.COMMON.Cancel	Action Modals	Action in change language modal	Cancel	Abbrechen	Action (button)						
I18N.DIGITALCONTRACT.notificationContractSent	In contract notification	Notification that contract was sent to contract partner	The contract was successfully sent to the buyer.	Der Vertrag wurde erfolgreich an den Käufer gesendet.	Body (text)						
I18N.DIGITALCONTRACT.notificationChangesSaved	In contract notification	Notification that contract changes were saved	Your changes have been saved.	Deine Änderungen wurden gespeichert.	Body (text)						
I18N.DIGITALCONTRACT.notificationChangesNotSaved	In contract notification	Notification that contract changes were not saved	Your changes have not been saved.	Deine Änderungen wurden nicht gespeichert.	Body (text)						
I18N.DIGITALCONTRACT.notificationInputSaved	In contract notification	Notification that Input was saved	Your entries have been saved.	Deine Eingaben wurden gespeichert.	Body (text)						
I18N.DIGITALCONTRACT.notificationReminderSent	In contract notification	Notification that reminder was sent	Reminder successfully sent to {name/e-mail/phone number}	Erinnerung erfolgreich an {name/e-mail/phone number} gesendet	Body (text)						
```
