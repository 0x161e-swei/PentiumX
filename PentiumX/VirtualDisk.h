#include <fstream>
#include <string>
#pragma once

#define FAT_SIZE 79
#define CATALOG_OFFSET (1+2*FAT_SIZE)
#define BLOCK_SIZE 512
#define DATA_OFFSET (CATALOG_OFFSET+32)

#define FILE_READWRITE 0
#define FILE_READONLY 1
#define FILE_HIDDEN 2
#define FILE_SYSTEM 4
#define FILE_LABEL 8
#define FILE_SUB_DIR 16
#define FILE_MODIFIED 32

// Ŀ¼��ṹ
struct CatalogItem
{
	char name[8];
	char extension[3];
	unsigned char nature;
	char reserved[10];
	unsigned short time;
	unsigned short date;
	unsigned short startingSector;
	unsigned int size;
};

struct File
{
	char name[8];
	char extension[3];
	unsigned char nature;
	unsigned short time;
	unsigned short date;
	char* content;
	unsigned int size;
	~File()
	{
		delete [] content;
	}
};

class VirtualDisk
{
public:
	~VirtualDisk();
	/**
	*@brief ���øú�����ȡ�����ָ��
	*/
	static VirtualDisk* getInstance();
	// ���ַ����л���ļ���,���Դ�Сд
	static bool getName(std::string& Name, std::string& str);
	// ���ַ����л���ļ���չ��,���Դ�Сд
	static bool getExtension(std::string& extension, std::string& str);
	// ���������ַ������ļ�������\0��ʾ��β�������Ҫָ������
	static void strcpy_v(char* dst, const char* src, int size);
	// �����Ƚ��ļ����Ƿ���ͬ,�ļ�������\0��ʾ��β�������Ҫָ������
	static bool strcmp_v(const char* str1,const char* str2, int size);
	
	/**
	*@brief �Ӵ����ж�ȡһ���ļ�
	*@return ����ָ���ļ���ָ�룬�����ʧ���򷵻�nullptr
	*/
	File* read(std::string& fileName);
	/**
	*@brief д��һ���ļ�������
	*@return д��ɹ�����true,���򷵻�false
	*/
	bool write(const File* file);
	/**
	*@brief ɾ��һ���ļ�
	*@return ɾ���ɹ�����true��ʧ���򷵻�false
	*/
	bool deleteFile(std::string& fileName);
	/// @brief ��ʽ������
	bool formatting();
	/// @brief dirָ��
	void dir();
	/// @brief renameָ��
	void rename(std::string& oldName, std::string& newName);
	/// @brief copyָ��
	void copy(std::string& oldName, std::string& newName);

private:
	VirtualDisk();
	// д��һ�����ļ�
	bool writeNewFile(CatalogItem* item, const int positionForFile, const char* content);
private:
	std::fstream vhd;	
};
