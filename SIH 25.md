# SIH 25

Team Name: Big O(6)

PS: 25002 - Smart Tourist Safety Monitoring & Incident Response System using Al, Geo-Fencing, and Blockchain-based Digital ID

**Problem Statement**

This problem statement proposes the development of a Smart Tourist Safety Monitoring & Incident Response System that leverages AI, Blockchain, and Geo-Fencing technologies. The system should include:

**Digital Tourist ID Generation Platform** 

- A secure blockchain-based system that issues digital IDs to tourists at entry points (airports, hotels, check-posts).
- These IDs should include basic KYC (Aadhaar/passport), trip itinerary, and emergency contacts, and be valid only for the duration of the visit.

**Mobile Application for Tourists** 

- Auto-assign a Tourist Safety Score based on travel patterns and area sensitivity.
- Geo-fencing alerts when tourists enter high-risk or restricted zones.
- Panic Button with live location sharing to nearest police unit and emergency contacts.
- Optional real-time tracking feature (opt-in) for families and law enforcement.

**AI-Based Anomaly Detection** 

- Detect sudden location drop-offs, prolonged inactivity, or deviation from planned routes.
- Flag missing, silent, or distress behaviour for investigations.

**Tourism Department & Police Dashboard** 

- Real-time visualizations of tourist clusters and heat maps of high-risk zones.
- Access to digital ID records, alert history, and last known locations.
- Automated E-FIR generation for missing person cases.

**IoT Integration (Optional)** 

- Smart bands or tags for tourists in high-risk areas (e.g., caves, forests).
- Continuous health/location signals and manual SOS feature.

**Multilingual Support** 

- App and platform available in 10+ Indian languages and English.
- Voice/text emergency access for elderly or disabled travellers.

**Data Privacy & Security** 

- End-to-end encryption and compliance with data protection laws.
- Blockchain ensures tamper-proof identity and travel records.

**Background**

In regions like the Northeast, where tourism is a key economic driver, ensuring the safety of visitors is paramount. Traditional policing and manual tracking methods are insufficient in remote and high-risk areas. There is a pressing need for a smart, technology-driven solution that ensures real-time monitoring, rapid response, and secure identity verification for tourists, while maintaining privacy and ease of travel.

**Expected Solution**

A robust digital ecosystem comprising:

- Web portal and mobile app for tourists and authorities.
- AI/ML models for behaviour tracking and predictive alerts.
- Blockchain-based ID generation and verification.
- Real-time dashboards for police/tourism departments.
- Optional IoT wearable integration for enhanced safety.
- Automated alert dispatch and evidence logging systems.

---

## Tech Stack:

NEXT, EXPRESS, POSTGRESQL, FLUTTER, SOLIDITY

ML: PYTHON, FASTAPI, SCIKIT LEARN

## Features:

| **Platform** | **Stakeholders** | **Features** | **Details** |
| --- | --- | --- | --- |
| **Mobile App (Tourist App)** | Tourists, Families | Digital Tourist ID (linked to blockchain) | KYC at entry (passport/Aadhaar), trip itinerary, emergency contacts, valid only for trip duration |
|  |  | Auto Safety Score | Based on travel patterns, area sensitivity, and real-time movement |
|  |  | Geo-fencing alerts | Notification when entering high-risk or restricted zones |
|  |  | Panic Button with live location | Sends location to police, tourism dept, and family simultaneously |
|  |  | Multilingual Support | 10+ Indian languages + English, with voice/text options |
|  |  | Family Tracking (opt-in) | Families can view live location and receive inactivity/SOS alerts |
|  |  | Tourist Feedback | Post-trip/incident ratings for safety and reporting |
| **Web Portal (Tourism Dept.)** | Tourism Department, Airport/Border Authorities | Digital ID Issuance & Management | Register tourists at airports, hotels, and borders, manage KYC & blockchain IDs |
|  |  | Risk Zone Heatmaps | Visualize unsafe or restricted tourist clusters on GIS map |
|  |  | Tourist Cluster Monitoring | Real-time movement monitoring and density visualization |
|  |  | Feedback Analytics | Analyze tourist feedback and incidents to improve safety policies |
| **Web Portal (Police & Emergency)** | Police, Law Enforcement, Emergency Services | Real-time SOS Dashboard | Immediate alerts with tourist ID, location, and trip details |
|  |  | AI Anomaly Detection | Detect deviations, inactivity, or distress patterns |
|  |  | Automated e-FIR Generation | Auto-fills missing person reports with digital ID & last known data |
|  |  | Unified Emergency Dispatch | Single platform connecting police, ambulance, fire, disaster management |
|  |  | Secure ID Access | Verify tourist identity and itinerary from blockchain records |
| **Blockchain Layer** | All Authorities, Tourists | Digital ID Storage & Verification | Tamper-proof storage of KYC, itinerary, and visit validity |
|  |  | Incident & Alert Logs | Immutable records of alerts, SOS, and e-FIRs for legal proof |
|  |  | Access Control | Granular access for police, tourism, and families without central tampering |
|  |  | Optional Incentive Mechanism | Reward system for community alerts or safe behavior |
| **IoT Layer (Optional)** | Tourists, Police, Emergency Services | Smart Bands/Tags | Continuous vitals + GPS tracking, SOS button for remote/high-risk areas |
|  |  | IoT Data Integration | Feed health/location signals directly to dashboards for faster response |

### Target Users:

- **Tourists (domestic & international)** – end users of safety app and digital ID
- **Families of tourists** – receive alerts and real-time tracking (opt-in)
- **Tourism Department** – manages IDs, dashboards, safety monitoring
- **Police & Law Enforcement** – respond to alerts, track incidents
- **Emergency Services (ambulance, rescue, fire)** – quick response in crises
- **Hotels & Travel Agencies** – help register tourists into the system
- **Airport/Border Authorities** – issue IDs at entry points
- **Local Communities & Businesses** – benefit from safer tourism

### Problems Faced and Unique Solutions:

| **Stakeholder** | **Problem Faced** | **Unique Solution** |
| --- | --- | --- |
| **Tourists** | Lack of awareness about safe/unsafe areas before travel | Safety navigation assistant with pre-trip risk alerts and safer route suggestions |
| **Families of Tourists** | Difficulty in contacting local authorities from abroad | Family-side portal/app to raise alerts directly to local police if loved one is unresponsive |
| **Tourism Department** | Inability to measure tourist satisfaction with safety initiatives | Feedback analytics from tourists post-incident or post-trip to refine policies |
| **Police & Law Enforcement** | Duplicate or false alerts waste response resources | AI-driven alert validation using digital ID + movement patterns |
| **Emergency Services** | Coordination gaps between multiple emergency units | Unified command dashboard linking police, ambulance, and disaster teams |
| **Hotels & Travel Agencies** | Tourists often don’t share full trip plans beyond hotel booking | Integrated itinerary upload during check-in for safer monitoring |
| **Airport/Border Authorities** | Difficulty in quick verification of international travel documents | AI-powered document scanning + blockchain registration for instant ID generation |
| **Local Communities & Businesses** | No trusted channel to report tourist-related incidents | Community alert system in app for flagging unsafe spots, scams, or incidents |

## Feasibility and viability:

| **Feasibility** | **Challenges & Risks** | **Strategies to Overcome** |
| --- | --- | --- |
| Mobile app (Flutter) is technically straightforward: GPS, alerts, panic button, multilingual UI | Tourist hesitation in sharing personal data | Make digital ID issuance part of mandatory onboarding at airports/hotels, keep real-time tracking optional |
| Web portals (Tourism & Police) can be built with mature web/GIS/analytics tools | Resistance from authorities in adopting new digital workflows | Pilot deployments + training programs for police/tourism staff |
| Blockchain layer ensures tamper-proof IDs & records (Polygon/Hyperledger feasible) | Handling sensitive KYC and personal data securely | End-to-end encryption, compliance with India’s Data Protection Bill, granular access control |
| AI/ML anomaly detection feasible with Python + FastAPI + scikit-learn | False alarms may overwhelm law enforcement | AI-based alert validation using digital ID + movement patterns before escalation |
| IoT smart bands/tags feasible for pilots in high-risk zones | Network connectivity issues in remote areas | Offline-first app design + IoT devices with store-and-forward data sync |
| Cloud-based scalable infra possible with modular architecture | High implementation and maintenance costs | Government funding, PPP (public-private partnership), optional revenue via IoT rentals/insurance tie-ups |
|  |  |  |

## Datasets:

https://www.data.gov.in/catalog/crime-india-2022

## Research:

[**Peng, Lei & Chen, Yan. (2021). Tourism safety monitoring information service system based on internet of things and block-chain. Journal of Intelligent & Fuzzy Systems. 1-7. 10.3233/JIFS-219101.**](https://www.researchgate.net/publication/352236507_Tourism_safety_monitoring_information_service_system_based_on_internet_of_things_and_block-chain)

[**https://timesofindia.indiatimes.com/life-style/travel/news/six-nations-warn-against-visiting-northeast-india-what-it-means-for-tourists/articleshow/119532126.cms**](https://timesofindia.indiatimes.com/life-style/travel/news/six-nations-warn-against-visiting-northeast-india-what-it-means-for-tourists/articleshow/119532126.cms)

[**https://timesofindia.indiatimes.com/city/kolkata/jawan-dials-112-gets-lost-bike-back-in-1-hr/articleshow/121786307.cms**](https://timesofindia.indiatimes.com/city/kolkata/jawan-dials-112-gets-lost-bike-back-in-1-hr/articleshow/121786307.cms)

[**https://hospitality.economictimes.indiatimes.com/news/travel/indians-emerge-as-apacs-most-confident-travellers-booking-com-travel-confidence-index/92762327**](https://hospitality.economictimes.indiatimes.com/news/travel/indians-emerge-as-apacs-most-confident-travellers-booking-com-travel-confidence-index/92762327)

## PPT:

- [x]  Use Case Diagram
- [x]  Architecture Diagram