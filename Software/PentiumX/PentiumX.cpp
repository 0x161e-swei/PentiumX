// PentiumX.cpp : 定义控制台应用程序的入口点。
#include "stdafx.h"

#define THREAD_NUM 2
using namespace std;

HANDLE hThread[THREAD_NUM];



DWORD CpuRun(LPVOID lpParam)
{
	DWORD exitCode = 0;
	MipsCPU* cpu = MipsCPU::GetInstance();
	for (;;)
	{
		cpu->Step();
		GetExitCodeThread(hThread[1], &exitCode);
		if (exitCode != STILL_ACTIVE)
		{
			delete cpu;
			ExitThread(0);
		}
		Sleep(0);
	}
	return 0;
}

void Display2(int value)
{
	MipsCPU* cpu = MipsCPU::GetInstance();
	int begin = GetTickCount64();
	cpu->VgaRun();
	int end = GetTickCount64();
	// 每40ms画一次
	glutTimerFunc(max(0, 40-(end-begin)), Display2, NULL);
}

void Display1()
{	
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	Display2(NULL);
}

void ProcessKey(byte key, int x, int y)
{
	MipsCPU* cpu = MipsCPU::GetInstance();
	cpu->KbInt(key);
}

void ProcessSpecialKey(int key, int x, int y)
{
	MipsCPU* cpu = MipsCPU::GetInstance();
	switch (key) {
	case GLUT_KEY_UP:
		key = 0xff01;
		break;
	case GLUT_KEY_DOWN:
		key = 0xff02;
		break;
	case GLUT_KEY_LEFT:
		key = 0xff03;
		break;
	case GLUT_KEY_RIGHT:
		key = 0xff04;
		break;
	default:
		return;
	}
	cpu->KbInt(key);
}


DWORD Vga(LPVOID lpParam)
{
	glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE);
	glutInitWindowPosition(100, 100);
	glutInitWindowSize(640, 480);
	glutCreateWindow("VGA");
	glutDisplayFunc(Display1);
	glutKeyboardFunc(ProcessKey);
	glutSpecialFunc(ProcessSpecialKey);
	glutMainLoop();

	return 0;
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nShowCmd)
{
	MipsCPU::GetInstance();

	//glutInit(&argc, argv);
	MipsCPU* cpu = MipsCPU::GetInstance();
	if (cpu->Boot() == false) {
		MessageBox(NULL, L"Boot failed", L"Warning", MB_OK);
		return 0;
	}

	hThread[0] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)CpuRun, 0, 0, NULL);
	hThread[1] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)Vga, 0, 0, NULL);

	WaitForMultipleObjects(THREAD_NUM, hThread, TRUE, INFINITE);

	return 0;
}
