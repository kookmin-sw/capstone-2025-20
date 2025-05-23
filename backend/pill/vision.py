import base64
from openai import OpenAI
from pill.APIsettings import ApiConstants

client = OpenAI(api_key=ApiConstants.openai_api_key)

def extract_appearance_data(image_file):
    image_bytes = image_file.read()
    base64_image = base64.b64encode(image_bytes).decode('utf-8')

    prompt = (
        "이미지를 보고 알약의 외형 정보를 추출하라. 응답은 아래 형식의 JSON으로만 하며, "
        "어떠한 문장이나 설명도 포함하지 않는다.\n"
        "응답 형식\n"
        "{\n"
        "  \"shape\": [...],   // 모양\n"
        "  \"color\": [...],   // 색상\n"
        "  \"form\": [...],    // 제형\n"
        "  \"line\": [...],    // 분할선\n"
        "  \"text\": [...]     // 식별 문자\n"
        "}\n"
        "항목별 응답 기준\n"
        "\"shape\" (list of string)\n"
        "\t•\t알약의 모양.\n"
        "\t•\t아래 중 하나만 골라 리스트에 담아 응답한다:\n"
        "원형, 타원형, 장방형, 삼각형, 사각형, 마름모, 오각형, 육각형, 팔각형, 기타, null\n\n"
        "\"color\" (list of string)\n"
        "\t•\t알약의 주요 색상.\n"
        "\t•\t아래 중 하나만 골라 리스트에 담는다:\n"
        "빨강, 자주, 분홍, 주황, 노랑, 초록, 연두, 청록, 파랑, 남색, 보라, 갈색, 하양, 검정, 투명, null\n\n"
        "\"form\" (list of string)\n"
        "\t•\t알약의 제형.\n"
        "\t•\t아래 중 하나만 선택해 리스트로 응답한다:\n"
        "정제, 경질캡슐, 연질캡슐\n\n"
        "\"line\" (list of string)\n"
        "\t•\t분할선의 종류.\n"
        "\t•\t가능한 값:\n"
        "\t•\t없음: []\n"
        "\t•\t일자형: [\"-\"]\n"
        "\t•\t십자형: [\"+\"]\n"
        "\t•\t둘 다 존재: [\"-\", \"+\"]\n\n"
        "\"text\" (list of string)\n"
        "\t•\t식별 문자.\n"
        "\t•\t식별 가능한 문자(숫자+영문 조합)를 한 면에 하나씩 문자열로 저장하며, 앞뒷면 둘 다 보일 경우 리스트 길이는 2가 된다.\n"
        "\t•\t예: [\"AB\", \"12\"]\n"
        "\t•\t한 면만 보일 경우: [\"AB\"]"
    )

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": prompt},
            {
                "role": "user",
                "content": [
                    {
                        "type": "image_url",
                        "image_url": f"data:image/jpeg;base64,{base64_image}"
                    }
                ]
            }
        ],
        response_format="json",
        temperature=0,
        max_tokens=2048,
        top_p=1
    )

    return response.choices[0].message.content