# 🧠 AskDAH – AI-Powered University Chatbot App  
_Transforming Student Services at Dar Al-Hekma University using Generative AI and Flutter_

![AskDAH App Screenshot](https://raw.githubusercontent.com/fatma-ai-coder/Capstone-Chatbot/main/App_SC.png)
---

📚 **Project Overview**  
AskDAH is a mobile application developed as a Capstone Project at Dar Al-Hekma University. It integrates a Generative AI Chatbot with a centralized event calendar to solve the problem of delayed responses and scattered communication across campus systems.

Built with Flutter, Firebase, Microsoft Azure, and OpenAI's GPT-4, the app delivers a seamless platform for real-time academic and administrative support, enabling students to easily access services, ask questions, and explore university events.

---

🔍 **Problem Statement**  
Students face challenges accessing timely, accurate information from various departments. Email overload, unstructured platforms, and communication delays are common. AskDAH addresses this with an intelligent, interactive, and user-friendly solution powered by RAG (Retrieval-Augmented Generation) architecture.

---

🎯 **Objectives**  
- Enable students to ask academic or administrative questions via a ChatGPT-based assistant  
- Provide a document-aware chatbot that retrieves answers from real DAH materials  
- Centralize event visibility through a calendar feature categorized by department and service type  
- Reduce reliance on scattered communication channels like email  

---

🛠️ **Tech Stack**  

| Area            | Technologies Used                           |
|-----------------|----------------------------------------------|
| Frontend        | Flutter, Dart                                |
| Backend         | Firebase (Firestore, Functions), MongoDB     |
| AI/NLP          | OpenAI GPT-4 API, LangChain, Chroma, FAISS   |
| Authentication  | Microsoft Azure (OAuth2)                     |
| Design Tools    | Figma, Android Studio                         |

---

💬 **Chatbot Architecture**  
AskDAH features two versions:

- **Chatbot 1:** RAG model using LangChain, Chroma DB, and GPT-4  
- **Chatbot 2:** Document QA using FAISS and LangChain with static queries  

Both were evaluated on real student questions to ensure accuracy, robustness, and ethical response behavior.

---

✅ **Evaluation Summary**

| Metric              | Chatbot 1 | Chatbot 2 |
|---------------------|-----------|-----------|
| Functionality       | 5/5       | 5/5       |
| Accuracy            | 4/5       | 4/5       |
| Robustness          | 5/5       | 3/5       |
| Relevance           | 4/5       | 3/5       |
| UX Design           | 5/5       | 4/5       |
| Security & Ethics   | 5/5       | 3/5       |

- ✔️ Chatbot 1 was approved for campus-wide use.  
- ⚠️ Chatbot 2 is a prototype with limitations in filtering unrelated queries.

---

📱 **Key Features**  
- ✅ AI-powered Q&A based on DAH documents  
- 📅 Real-time event calendar with categorized filters  
- 🌗 Light & Dark Mode support  
- 🔒 Microsoft login for contextual user queries  
- 🧠 Query preprocessing using NLTK  
- 📂 Secure OpenAI API integration and data management  

---

🏆 **Highlights**  
- 📍 Participated in UoJ Digital Innovation Hackathon  
- 🎤 Presented at CCTS 2023 Conference  
- 🧪 Conducted full user testing with real student queries  
- 🛡 Built with ethical AI and data security in mind  

---

💡 **Future Recommendations**  
- Add Arabic-language support and voice interaction  
- Expand chatbot to support course registration and GPA calculation  
- Migrate to Pinecone for scalable embedding storage  
- Deploy a live beta version for internal campus testing  

---

📄 **Full Report**  
To learn more about the system architecture, evaluation, and development process, you can read the full Capstone Report here:  
📎 [AskDAH Report (DOCX)](https://github.com/fatma-ai-coder/Capstone-Chatbot/raw/main/Ask_DAH_Report.pdf
)

---
