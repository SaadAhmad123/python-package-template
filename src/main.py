import os, re
from mangum import Mangum
from api.v1 import api_v1_router
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
load_dotenv()

def make_proper_path(path: str) -> str:
    return re.sub(r'/+', '/', path)

PROXY_PREFIX: str = os.environ.get("PROXY_PREFIX", "").strip()
LAMBDA_STAGE: str = os.environ.get("LAMBDA_STAGE", "").strip()
OPEN_API_PREFIX = '/'.join(filter(lambda x: x is not None and len(x.strip()), [LAMBDA_STAGE, PROXY_PREFIX]))
API_GATEWAY_BASE_PATH = PROXY_PREFIX if len(PROXY_PREFIX) else OPEN_API_PREFIX

print({
  "PROXY_PREFIX": PROXY_PREFIX,
  "LAMBDA_STAGE": LAMBDA_STAGE,
  "OPEN_API_PREFIX": OPEN_API_PREFIX,
  "API_GATEWAY_BASE_PATH": API_GATEWAY_BASE_PATH,
})

app = FastAPI(openapi_prefix=make_proper_path(f"/{OPEN_API_PREFIX}"))
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)
app.include_router(api_v1_router)


lambda_handler = Mangum(app, api_gateway_base_path=make_proper_path(f"/{API_GATEWAY_BASE_PATH}"))