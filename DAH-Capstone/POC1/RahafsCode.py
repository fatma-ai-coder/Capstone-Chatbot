from openai import OpenAI

client = OpenAI (api_key= "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")

#Api key obtain from the website


#choosing the model
def chat_with_gpt(massage):
    response = client.completions.create(
        model = "gpt-3.5-turbo-instruct",
        prompt= massage,
        max_tokens= 150)  

    return response.choices[0].text.strip() #to erase whitespaces


#Simple loop to make the user keep asking questions
while True:
    user_input = input("You:")
    if user_input.lower() == 'quit':
        break
       
    response = chat_with_gpt(user_input)
    print("Chatbot: ", response )