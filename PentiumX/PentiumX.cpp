// PentiumX.cpp : 定义控制台应用程序的入口点。
#include "stdafx.h"

#define THREAD_NUM 2
using namespace std;

HANDLE hThread[THREAD_NUM];



DWORD cpuRun(LPVOID lpParam)
{
	DWORD exitCode = 0;
	MipsCPU* cpu = MipsCPU::getInstance();
	for (;;)
	{
		cpu->step();
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

void display2(int value)
{
	MipsCPU* cpu = MipsCPU::getInstance();
	int begin = GetTickCount64();
	cpu->vgaRun();
	int end = GetTickCount64();
	// 每40ms画一次
	glutTimerFunc(max(0, 40-(end-begin)), display2, NULL);
}
void display1()
{	
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	display2(NULL);
}

void processKey(byte key, int x, int y)
{
	MipsCPU* cpu = MipsCPU::getInstance();
	cpu->kbInt(key);
}

void processSpecialKey(int key, int x, int y)
{
	switch (key)
	{
	case GLUT_KEY_F4:
		int mod = glutGetModifiers();
		if (mod == GLUT_ACTIVE_ALT)
		{
			ExitThread(0);
		}
		break;// alt+F4结束程序
	}
}

DWORD vga(LPVOID lpParam)
{
	glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE);
	glutInitWindowPosition(100, 100);
	glutInitWindowSize(640, 480);
	glutCreateWindow("VGA");
	glutDisplayFunc(display1);
	glutKeyboardFunc(processKey);
	glutSpecialFunc(processSpecialKey);
	glutMainLoop();

	return 0;
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nShowCmd)
{
	MipsCPU::getInstance();

	//glutInit(&argc, argv);
	MipsCPU* cpu = MipsCPU::getInstance();
	if (cpu->Boot() == false) {
		MessageBox(NULL, L"Boot failed", L"Warning", MB_OK);
		return 0;
	}

	hThread[0] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)cpuRun, 0, 0, NULL);
	hThread[1] = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)vga, 0, 0, NULL);

	WaitForMultipleObjects(THREAD_NUM, hThread, TRUE, INFINITE);

	return 0;
}
