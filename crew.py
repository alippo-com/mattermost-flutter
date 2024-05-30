import os
from pathlib import Path
import re
from crewai import Agent, Task, Crew
from crewai_tools import FileReadTool, DirectoryReadTool
from langchain_openai import ChatOpenAI
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_anthropic import ChatAnthropic
from langchain_community.chat_models import ChatOllama
from crewai.process import Process

from tools.FileWriter import FileWriter

# Environment setup
os.environ["OPENAI_API_KEY"] = "<>"
os.environ["GOOGLE_API_KEY"] = "<>"
os.environ["ANTHROPIC_API_KEY"] = (
    "<>"
)

# Ollama
# os.environ["OPENAI_API_BASE"] = "http://localhost:11434/v1"
# os.environ["OPENAI_MODEL_NAME"] = "crewai-llama3"
# os.environ["OPENAI_API_KEY"] = 'ollama'

source_directories = ["./mattermost-mobile/app", "./mattermost-mobile/types"]
flutter_project_root = "./mattermost_flutter"
Path(flutter_project_root).mkdir(parents=True, exist_ok=True)

llm = ChatOpenAI(model="gpt-4o")
# llm = ChatGoogleGenerativeAI(model="gemini-1.5-pro-latest")
# llm = ChatAnthropic(model="claude-3-opus-20240229")
# llm = ChatOpenAI(model="crewai-llama3", base_url = "http://localhost:11434", openai_api_key="")

# Initialize tools
file_read_tool = FileReadTool()
file_writer_tool = FileWriter()
directory_tool = DirectoryReadTool()


def read_files(directory):
    """Recursively read all .ts and .tsx files in the specified directory."""
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith((".tsx", ".ts")):
                with open(os.path.join(root, file), "r", encoding="utf-8") as f:
                    content = f.read()
                yield (os.path.join(root, file), content)

def parse_imports(file_content):
    """Extract import statements from file content."""
    imports = re.findall(
        r'^import .*? from ["\'](.+?)["\'];$', file_content, re.MULTILINE
    )
    return imports


def create_dependency_graph():
    """Generate a dependency graph from the imports in all files."""
    graph = {}
    for directory in source_directories:
        for file_path, content in read_files(directory):
            imports = parse_imports(content)
            graph[file_path] = imports
    return graph


def create_migration_tasks(dependency_graph):
    """Create migration tasks based on the dependency graph."""
    sorted_files = sorted(
        dependency_graph, key=lambda file: len(dependency_graph[file])
    )
#     sorted_files = [
#         "./mattermost-mobile/app/products/calls/screens/participants_list/index.ts",
#         "./mattermost-mobile/app/products/calls/screens/participants_list/participant.tsx",
#         "./mattermost-mobile/app/products/calls/screens/participants_list/participant.tsx",
#         "./mattermost-mobile/app/products/calls/screens/participants_list/pill.tsx",
#         "./mattermost-mobile/app/components/team_sidebar/index.ts",
#     ]
    total_files = len(sorted_files)
    tasks = []
    startIndex = 999999999
    for index, file_path in enumerate(sorted_files):
#     print(sorted_files)
#     for index, file_path in enumerate(sorted_files):
        # if file_path in ["./mattermost-mobile/app/screens/post_options/options/edit_option.tsx"]:
        #     startIndex = index
        # if index < startIndex:
        #     continue
        task = Task(
            description=f"Convert source file from React Native to Dart, write to the flutter project directory at an appropriate path, and get the conversion reviewed."
            f"This is file {1} of {total_files}."
            f" Here is the required data to complete the task - source_file: {file_path}, flutter_project_root: {flutter_project_root} and flutter_package_name: mattermost_flutter."
            " All import for @typing directive in react-native should be imported from types directory in flutter."
            " Use sqflite in place of watermelondb wherever required."
            f" Ask for human input for review.",
            expected_output=f"Converted dart file successfully written to the destination directory after approved review",
            agent=code_converter,
            # human_input=True,
        )
        tasks.append(task)
    return tasks


# Initialize Crew
code_converter = Agent(
    role="Conversion Agent",
    backstory="Converts React Native code to Flutter, adhering to project requirements, and writes the output to a specified directory. You wont have a tool for conversion, you have to convert the code using the LLM model.",
    goal="Convert the project's TypeScript and TSX files to Flutter efficiently and ensure they are saved correctly."
    " Send the following params to the reviewer: source_file_path, converted_file_path, flutter_project_root, flutter_package_name."
    " Sometimes reviewer may come back saying that it did not find the file in the path you provided, in that case dont write the file to the path that reviewer provided, instead look back at the path you saved in your memory, confirm if the file is present and then send the correct path to the reviewer for review."
    " For package.json file, you have to convert the dependencies to appropriate flutter dependencies.",
    allow_delegation=True,
    tools=[
        file_read_tool,
        file_writer_tool,
        # directory_tool,
    ],  # Agent is equipped with both reading and writing tools
    llm=llm,
    # llm="crewai-llama3"
    # max_rpm=30,
    verbose=True,
    cache= False 
)

reviewer = Agent(
    role="Review Agent",
    backstory="You are an expert both in React native and Flutter."
    "You review the converted Dart code from React native to ensure it meets Flutter best practices and checks for appropriate library usage."
    " Make sure you get path of both source and converted file for review so that you can read those files and review them."
    " You also have to review the path of the converted file in the flutter project.",
    goal="Review and verify the converted Dart files against the source react native files for accuracy and best practices."
    " Make sure you get path of both source and converted file for review so that you can read those files and review them." 
    " You also have to review the path of the converted file in the flutter project."
    " If only you need any changes, you can ask the conversion agent to make the changes and review again. But if you approve the conversion, dont write the file to the flutter project directory because the conversion agent would have already done that.",
    tools=[
        file_read_tool,
        # directory_tool,
    ],  # Agent is equipped with both reading and writing tools
    llm=llm,
    # llm="crewai-llama3"
    # max_rpm=30,
    verbose=True,
    cache= False 
)

# Generate the dependency graph and create tasks
dependency_graph = create_dependency_graph()
migration_tasks = create_migration_tasks(dependency_graph)
crew = Crew(
    agents=[code_converter, reviewer], 
    tasks=migration_tasks, 
    verbose=2, 
    # memory=True,
    process= Process.sequential,
    # manager_llm=ChatOpenAI(temperature=0, model="gpt-4o"),
    usage_metrics=True,
    output_log_file=True
)

# Kickoff the process and print results
result = crew.kickoff()
print(result)

