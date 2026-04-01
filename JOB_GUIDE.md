# Task
youtube url을 파라미터로 제공하면 이 url의 음성파일을  mp3 추출하는 python cli 프로그램

# Usage
'
ExtarctAudio https://youtu.be/WbHDsHqt6ug?si=CtCzTih3jWf7XAC1

'

# 요구사항
- 맥에 설치해서 사용 할 수 있는 cli프로그램 형태로 제작
- Extract Audio --help, -h 명령어를 입력하면 간단한 사용법 표시
- '-d' 옵션 뒤에 파일 경로를 지정하면 파일경로에 mp3파일 파일 저장, 없으면 현재 디렉토리에 저장
- '-name' 옵션을 지정하면 mp3 파일명 지정 가능. 없으면 youtube 타이틀이름으로 파일명 생성 

# 기술 스펙
- python을 이용해서 제작
- LLM이 필요한 경우 .env파일에 key값을 저장하도록 설정

# 코딩 가이드
- 코딩을 하기전에 계획을 수립하고 나에게 확인을 받아야 함
- 요구사항 중 이해가 안되는 부분이 있으면 계획을 수립하는 단계에서 먼저 질문해서 확인
- 코딩이 완료되면 단위 테스트와 전체 테스트
- 프로그램이 완성되면 README.md파일에 간단한 사용법 기재

