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

// 目录项结构
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
	*@brief 调用该函数获取类对象指针
	*/
	static VirtualDisk* getInstance();
	// 从字符串中获得文件名,忽略大小写
	static bool getName(std::string& Name, std::string& str);
	// 从字符串中获得文件扩展名,忽略大小写
	static bool getExtension(std::string& extension, std::string& str);
	// 用来拷贝字符串，文件名不用\0表示结尾，因此需要指定长度
	static void strcpy_v(char* dst, const char* src, int size);
	// 用来比较文件名是否相同,文件名不用\0表示结尾，因此需要指定长度
	static bool strcmp_v(const char* str1,const char* str2, int size);
	
	/**
	*@brief 从磁盘中读取一个文件
	*@return 返回指向文件的指针，如果打开失败则返回nullptr
	*/
	File* read(std::string& fileName);
	/**
	*@brief 写入一个文件到磁盘
	*@return 写入成功返回true,否则返回false
	*/
	bool write(const File* file);
	/**
	*@brief 删除一个文件
	*@return 删除成功返回true，失败则返回false
	*/
	bool deleteFile(std::string& fileName);
	/// @brief 格式化磁盘
	bool formatting();
	/// @brief dir指令
	void dir();
	/// @brief rename指令
	void rename(std::string& oldName, std::string& newName);
	/// @brief copy指令
	void copy(std::string& oldName, std::string& newName);
	/// @brief 读取指定段
	void readSection(unsigned short number, char* data);
	/// @brief 写入指定段
	void writeSection(unsigned short number, char* data);

private:
	VirtualDisk();
	// 写入一个新文件
	bool writeNewFile(CatalogItem* item, const int positionForFile, const char* content);
private:
	std::fstream vhd;	
};
