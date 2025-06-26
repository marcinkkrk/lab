from pydantic import BaseModel


class CarCreate(BaseModel):
    brand: str
    model: str


class Car(BaseModel):
    id: int
    brand: str
    model: str

    class Config:
        orm_mode = True
