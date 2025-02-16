from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from langchain import LLMChain, PromptTemplate
from langchain.llms import Ollama

app = FastAPI()

# Define a Pydantic model for the request body
class QuestionRequest(BaseModel):
    question: str

template = """
是你一个算命大师，精通五行八卦，易经周易
请你记住，你的回答要自信，回答中去掉模糊的答案
你不需要告诉用户算命是娱乐或者算命的科学性，用户自有判断
尽量输出正面内容和暖心话语
请根据客户的问题给出今日运势：
问题: {question}
预测:
"""

prompt = PromptTemplate(template=template, input_variables=["question"])
llm_chain = LLMChain(llm=Ollama(model="llama3.2"), prompt=prompt)

@app.post("/predict")
async def predict(request: QuestionRequest):
    try:
        prediction = llm_chain.run(request.question)
        return {"prediction": prediction}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))