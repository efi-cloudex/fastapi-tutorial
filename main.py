from fastapi import FastAPI

app = FastAPI()


@app.get("/items/{item_id}")
async def root(item_id):
    return {"message": f"Hello {item_id}"}