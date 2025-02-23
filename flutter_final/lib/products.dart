const List<Map<String, dynamic>> products = [
  // Medicines
  {
    "category": "Medicines",
    "id": "1",
    "name": "Paracetamol",
    "imageUrl": "/react-logo.png",
    "quantity": "10 tablets",
    "price": "5.99",
    "taxPercentage": "5",
    "description":
        "Paracetamol is a widely used pain reliever and fever reducer. It helps alleviate mild to moderate pain, such as headaches, muscle aches, and arthritis. It is also effective in reducing fever caused by infections and illnesses. This medication is suitable for adults and children when used as directed. It works by inhibiting the production of chemicals in the body that cause pain and fever. Overuse can lead to liver damage, so it should be taken in recommended doses. It is commonly available over the counter and is a staple in most first-aid kits. Always consult a doctor before use, especially for prolonged treatment.",
    "rating": 4.5
  },
  {
    "category": "Medicines",
    "id": "2",
    "name": "Ibuprofen",
    "imageUrl": "/react-logo.png",
    "quantity": "20 tablets",
    "price": "8.99",
    "taxPercentage": "4",
    "description":
        "Ibuprofen is a nonsteroidal anti-inflammatory drug (NSAID) used for pain relief and reducing inflammation. It is commonly used for conditions such as headaches, dental pain, arthritis, menstrual cramps, and minor injuries. Ibuprofen works by blocking enzymes responsible for inflammation and pain signals. It is effective for short-term use but should not be overused as it may cause stomach ulcers, kidney issues, or cardiovascular risks. This medication is best taken with food to avoid stomach irritation. It is available in different strengths and forms, including tablets and liquid suspensions.",
    "rating": 4.2
  },
  {
    "category": "Medicines",
    "id": "3",
    "name": "Vitamin C",
    "imageUrl": "/react-logo.png",
    "quantity": "30 capsules",
    "price": "12.99",
    "taxPercentage": "2",
    "description":
        "Vitamin C, also known as ascorbic acid, is an essential nutrient that supports the immune system and promotes healthy skin. It acts as a powerful antioxidant, protecting the body against free radical damage. Regular intake of Vitamin C helps improve wound healing, reduce the risk of chronic diseases, and enhance iron absorption. This supplement is beneficial for individuals with dietary deficiencies or increased vitamin needs. It is commonly used during cold and flu season to strengthen immunity. Overconsumption may cause digestive discomfort, so it is recommended to follow the dosage guidelines.",
    "rating": 4.8
  },
  {
    "category": "Medicines",
    "id": "4",
    "name": "Cough Syrup",
    "imageUrl": "/react-logo.png",
    "quantity": "150ml",
    "price": "6.49",
    "taxPercentage": "4",
    "description":
        "Cough syrup is formulated to provide relief from persistent cough and throat irritation. It contains active ingredients that help suppress coughing, loosen mucus, and soothe the throat. This medication is commonly used for dry or productive coughs associated with colds, flu, or respiratory infections. Some syrups may include antihistamines to reduce allergy-related coughing. It is important to take the syrup as per the recommended dosage to avoid drowsiness or other side effects. Consult a healthcare provider if symptoms persist beyond a few days.",
    "rating": 4.3
  },
  {
    "category": "Medicines",
    "id": "7",
    "name": "Aspirin",
    "imageUrl": "/react-logo.png",
    "quantity": "50 tablets",
    "price": "7.49",
    "taxPercentage": "3",
    "description":
        "Aspirin is a widely used analgesic and anti-inflammatory medication that also has blood-thinning properties. It is effective for relieving mild pain such as headaches, toothaches, and muscle soreness, as well as reducing inflammation in conditions like arthritis. Aspirin is also prescribed in low doses to prevent heart attacks and strokes by reducing blood clot formation. It should be taken with food to minimize stomach irritation. Prolonged use or high doses may lead to gastrointestinal bleeding or ulcers, so it’s essential to follow medical advice.",
    "rating": 4.4
  },
  {
    "category": "Medicines",
    "id": "8",
    "name": "Amoxicillin",
    "imageUrl": "/react-logo.png",
    "quantity": "15 capsules",
    "price": "14.99",
    "taxPercentage": "5",
    "description":
        "Amoxicillin is a broad-spectrum antibiotic used to treat bacterial infections such as ear infections, sinusitis, pneumonia, and urinary tract infections. It works by inhibiting the growth of bacteria, making it effective against a variety of pathogens. This medication is typically prescribed for a specific duration and should be completed even if symptoms improve to prevent antibiotic resistance. Common side effects include nausea and rash. It is not effective against viral infections like the flu. A doctor’s prescription is required.",
    "rating": 4.6
  },
  {
    "category": "Medicines",
    "id": "9",
    "name": "Loratadine",
    "imageUrl": "/react-logo.png",
    "quantity": "30 tablets",
    "price": "9.49",
    "taxPercentage": "2",
    "description":
        "Loratadine is an antihistamine used to relieve allergy symptoms such as sneezing, runny nose, itchy eyes, and throat irritation. It works by blocking histamine, a substance in the body that causes allergic reactions. This medication is non-drowsy, making it suitable for daytime use. It is commonly used for seasonal allergies, hay fever, and mild allergic reactions. Relief typically begins within an hour of ingestion. Over-the-counter availability makes it a popular choice, though it’s advised to consult a doctor for chronic conditions.",
    "rating": 4.7
  },
  {
    "category": "Medicines",
    "id": "10",
    "name": "Omeprazole",
    "imageUrl": "/react-logo.png",
    "quantity": "20 capsules",
    "price": "11.99",
    "taxPercentage": "4",
    "description":
        "Omeprazole is a proton pump inhibitor (PPI) used to reduce stomach acid production. It is effective for treating acid reflux, heartburn, ulcers, and gastroesophageal reflux disease (GERD). By decreasing acid levels, it helps heal the stomach lining and prevents damage from excessive acidity. It is usually taken before meals for optimal effect. Long-term use may require medical supervision due to potential side effects like nutrient deficiencies or kidney issues. It’s widely available both over-the-counter and by prescription.",
    "rating": 4.5
  },

  // Injections
  {
    "category": "Injections",
    "id": "11",
    "name": "Flu Vaccine",
    "imageUrl": "/react-logo.png",
    "quantity": "1 vial",
    "price": "15.99",
    "taxPercentage": "5",
    "description":
        "The flu vaccine is an essential preventive measure against seasonal influenza. It helps the body develop immunity by stimulating the production of antibodies against flu viruses. This vaccine is recommended for all age groups, especially children, elderly individuals, and those with weakened immune systems. It is formulated annually to target the most prevalent flu strains. Getting vaccinated reduces the risk of severe flu complications, hospitalizations, and transmission. Some mild side effects such as soreness at the injection site or mild fever may occur but usually subside quickly.",
    "rating": 4.7
  },
  {
    "category": "Injections",
    "id": "12",
    "name": "B12 Injection",
    "imageUrl": "/react-logo.png",
    "quantity": "1 vial",
    "price": "9.99",
    "taxPercentage": "3",
    "description":
        "Vitamin B12 injections are used to treat or prevent Vitamin B12 deficiency, which is essential for nerve function and red blood cell production. This injection is particularly beneficial for individuals with anemia, neurological disorders, or those who have difficulty absorbing B12 from food. Regular B12 supplementation helps boost energy levels, improve metabolism, and support brain function. The injection is administered intramuscularly and is often recommended for vegetarians, vegans, or those with gastrointestinal disorders. A healthcare professional should determine the correct dosage and frequency.",
    "rating": 4.5
  },
  {
    "category": "Injections",
    "id": "13",
    "name": "Insulin",
    "imageUrl": "/react-logo.png",
    "quantity": "10 ml",
    "price": "40.99",
    "taxPercentage": "5",
    "description":
        "Insulin injections are a vital treatment for diabetes, helping regulate blood sugar levels in individuals with Type 1 and Type 2 diabetes. This hormone allows the body to use glucose efficiently and prevents complications such as nerve damage, kidney failure, and cardiovascular diseases. Different types of insulin are available, including rapid-acting, intermediate, and long-acting formulations. Proper administration through subcutaneous injection is crucial for maintaining stable glucose levels. Regular monitoring and medical consultation are necessary to adjust doses based on lifestyle and dietary habits.",
    "rating": 4.8
  },
  {
    "category": "Injections",
    "id": "14",
    "name": "Hepatitis B Vaccine",
    "imageUrl": "/react-logo.png",
    "quantity": "1 vial",
    "price": "20.99",
    "taxPercentage": "5",
    "description":
        "The Hepatitis B vaccine protects against the Hepatitis B virus, which can cause severe liver damage, including cirrhosis and liver cancer. It is administered as a series of injections to stimulate immunity. This vaccine is recommended for infants, healthcare workers, and individuals at higher risk of exposure. It provides long-term protection with minimal side effects, such as mild soreness or fatigue. Completing the full vaccination schedule is critical for effectiveness. It’s a key part of preventive healthcare worldwide.",
    "rating": 4.9
  },
  {
    "category": "Injections",
    "id": "15",
    "name": "Tetanus Shot",
    "imageUrl": "/react-logo.png",
    "quantity": "1 vial",
    "price": "12.49",
    "taxPercentage": "4",
    "description":
        "The tetanus shot, often combined with diphtheria and pertussis vaccines (Tdap), protects against tetanus, a bacterial infection that causes muscle stiffness and lockjaw. It is recommended every 10 years or after potential exposure, such as through a deep wound. The vaccine works by prompting the immune system to produce antibodies against the tetanus toxin. Mild side effects like swelling or redness at the injection site are common. It’s an essential preventive tool, especially for those working in high-risk environments.",
    "rating": 4.6
  },
  {
    "category": "Injections",
    "id": "16",
    "name": "Ceftriaxone",
    "imageUrl": "/react-logo.png",
    "quantity": "1 vial",
    "price": "18.99",
    "taxPercentage": "5",
    "description":
        "Ceftriaxone is a powerful antibiotic injection used to treat serious bacterial infections, including meningitis, pneumonia, and sepsis. It belongs to the cephalosporin class and works by disrupting bacterial cell wall synthesis. This medication is typically administered in a hospital setting via intravenous or intramuscular injection. It’s effective against a wide range of bacteria but requires a prescription and medical supervision. Side effects may include diarrhea or allergic reactions, though rare. It’s crucial for critical care scenarios.",
    "rating": 4.7
  }
];
