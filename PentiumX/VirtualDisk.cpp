#include "VirtualDisk.h"
#include "windows.h"
#include <iostream>
#include <vector>
#include <algorithm>
#include <cctype>
using namespace std;

VirtualDisk* VirtualDisk::getInstance()
{
	static bool init = false;
	static VirtualDisk* vhd;
	if (init == false)
	{
		init = true;
		vhd = new VirtualDisk();
	}
	return vhd;
}

VirtualDisk::VirtualDisk()
{
	vhd.open("VirtualDisk.vhd", ios::binary|ios::in|ios::out);
}

VirtualDisk::~VirtualDisk()
{
	if (vhd.is_open())
	{
		vhd.close();
	}
}

bool VirtualDisk::formatting()
{
	if (!vhd.is_open())
	{
		return false;
	}

	// No.0 ����
	// Dos boot record
		vhd.seekp(0);

		vhd.write("\351\0\76", 3);	// 0x00 x86 jmp ָ��
		vhd.write("PX1.0", 8);		// 0x03 ��־�Ͱ汾��

		// BPB
		vhd.write("\2\0" // 0x0b ÿ���������ֽ���(2 bytes)
			"\1" // 0x0d ÿ��������(1 byte)
			"\0\1" // 0x0e ����������(2 bytes)
			"\2" // 0x10 FAT�����Ŀ(1 byte)
			"\2\0" // 0x11 ��Ŀ¼����(2 bytes)
			"\0\0" // 0x13 С������(2 bytes)
			"\370" // 0x15 ý��������(1 byte)
			"\0\117" // 0x16 ÿFAT������(2 bytes)
			"\0\77" // 0x18 ÿ��������(2 bytes)
			"\0\377" // 0x1a ��ͷ��(2 bytes) 
			"\0\0\0\77" // 0x1c ����������(4 bytes)
			"\0\0\120\0" // 0x20 ��������(4 bytes)
			, 25);

		// extended BPB
		vhd.write("\200" // 0x24 ������������(1 byte)
			"\0" // 0x25 ����(1 byte)
			"\50" // 0x26 ��չ������ǩ(1 byte)
			"\12\34\56\78" // 0x27 �����(4 bytes)
			"NO NAME\0\0\0\0" // 0x2b ���(11 bytes)
			"FAT16\0\0\0" // 0x36 �ļ�ϵͳ����(8 bytes)
			, 26);

		// bootstrap code(448 bytes)
		// ����û��boot����

		// ����������0x55aa(2 bytes)
		vhd.seekp(0x01fe);
		vhd.write("\125\252", 2);

		// FAT��Ĵ�СΪ79 blocks
		// 1+79+79+32+79*2^8 = 20415 blocks <= 20480 blocks = 10MB/(512B/block)
		// FAT����f8 ff ff ff��ͷ
		char *FAT, *catalog;
		FAT = new char[2*FAT_SIZE*BLOCK_SIZE];
		catalog = new char[32*BLOCK_SIZE];
		
		if (FAT == nullptr)
		{
			cout << "Memory Overflow" << endl;
			return false;
		}
		else
		{
			// ���FAT���Ŀ¼��
			memset(FAT, 0, 2*FAT_SIZE*BLOCK_SIZE);
			FAT[0] = (char)0xf8;
			FAT[1] = (char)0xff;
			FAT[2] = (char)0xff;
			FAT[3] = (char)0xff;
			FAT[FAT_SIZE*BLOCK_SIZE+0] = (char)0xf8;
			FAT[FAT_SIZE*BLOCK_SIZE+1] = (char)0xff;
			FAT[FAT_SIZE*BLOCK_SIZE+2] = (char)0xff;
			FAT[FAT_SIZE*BLOCK_SIZE+3] = (char)0xff;

			memset(catalog, 0, 32*BLOCK_SIZE);
			vhd.write(FAT, 2*FAT_SIZE*BLOCK_SIZE);
			vhd.write(catalog, 32*BLOCK_SIZE);
			delete[] FAT;
			delete[] catalog;
		}
	
	vhd.flush();
	return true;
}

File* VirtualDisk::read(string& fileName)
{
	CatalogItem item;
	string name, extension;
	if ((getName(name, fileName))!=true || (getExtension(extension, fileName))!=true)
	{
		cout << "Bad file name" << endl;
		return false;
	}
	int i;
	// �����ļ��Ƿ����
	for (i=CATALOG_OFFSET*BLOCK_SIZE; i<(CATALOG_OFFSET+32)*BLOCK_SIZE; i+=sizeof(CatalogItem)) 
	{
		vhd.seekg(i);
		vhd.read((char*)&item, sizeof(CatalogItem));
		if ((strcmp_v(item.name, name.c_str(), 8)==true) && (strcmp_v(item.extension, extension.c_str(), 3))==true)
		{
			break;
		}
	}
	// �ļ�������
	if (i >= (CATALOG_OFFSET+32)*BLOCK_SIZE)
	{
		cout << "Cannot find the file:" << fileName << endl;
		return nullptr;
	}
	else
	{
		// ���ļ���Ϣ
		File* file = new File;
		strcpy_v(file->name, name.c_str(), 8);
		strcpy_v(file->extension, extension.c_str(), 3);
		file->time = item.time;
		file->date = item.date;
		file->nature = item.nature;
		file->size = item.size;
		// �ҵ��ļ�λ��
		vector<unsigned short> sectorsOfFile;
		sectorsOfFile.push_back(item.startingSector);
		for (;;)
		{
			unsigned short num;
			vhd.seekg(BLOCK_SIZE+2*sectorsOfFile.back());
			vhd.read((char*)&num, 2);
			if (num != (unsigned short)0xffff)
			{
				sectorsOfFile.push_back(num);
			}
			else
			{
				break;
			}
		}
		// ���ļ�����
		file->content = new char[file->size];
		for (unsigned int j=0; j<sectorsOfFile.size(); j++)
		{
			vhd.seekg((DATA_OFFSET+sectorsOfFile[j]-2)*BLOCK_SIZE);
			if (j != sectorsOfFile.size()-1)
			{
				vhd.read(file->content+BLOCK_SIZE*j, BLOCK_SIZE);
			}
			else// ���һ���������⴦��
			{
				vhd.read(file->content+BLOCK_SIZE*j, file->size%BLOCK_SIZE);
			}
		}
		return file;
	}
}

bool VirtualDisk::write(const File* file)
{
	CatalogItem item;	
	int i;
	int positionForFile;
	bool positionFound = false;
	// �������ļ��Ƿ��Ѿ�����
	for (i=CATALOG_OFFSET*BLOCK_SIZE; i<(CATALOG_OFFSET+32)*BLOCK_SIZE; i+=sizeof(CatalogItem))
	{
		vhd.seekg(i);
		vhd.read((char*)&item, sizeof(CatalogItem));
		// Ϊ�ļ�Ŀ¼�ҳ���ŵ�λ��
		if (positionFound==false && strcmp_v(item.name, "", 8)==true)
		{
			positionForFile = i;	
			positionFound = true;
		}
		if (strcmp_v(item.name, file->name, 8)==true && strcmp_v(item.extension, file->extension, 3)==true)
		{
			positionForFile = i;
			break;
		}
	}
	if (i >= (CATALOG_OFFSET+32)*BLOCK_SIZE)// �����ļ�
	{
		if (positionFound == false)
		{
			cout << "Disk is full!" << endl;
			return false;
		}
		else
		{
			// ����Ŀ¼�����������
			strcpy_v(item.name, file->name, 8);
			strcpy_v(item.extension, file->extension, 3);
			item.nature = FILE_READWRITE;
			memset(item.reserved, 0, 10);
			SYSTEMTIME systemTime;
			GetLocalTime(&systemTime);
			item.time = (systemTime.wHour<<11)|((systemTime.wMinute&63)<<5)|((systemTime.wSecond&63)>>1);
			item.date = ((systemTime.wYear-1980)<<9)|((systemTime.wMonth&15)<<5)|(systemTime.wDay&31);
			item.size = file->size;
			// д�ļ�
			if (writeNewFile(&item, positionForFile, file->content) == true)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
	}
	else// ԭ�ļ��Ѿ�����
	{
		if (item.nature == FILE_READONLY)
		{
			cout << "The file is read-only" << endl;
			return false;
		}
		else
		{
			// �޸�Ŀ¼��
			SYSTEMTIME systemTime;
			GetLocalTime(&systemTime);
			item.time = (systemTime.wHour<<11)|((systemTime.wMinute&63)<<5)|((systemTime.wSecond&63)>>1);
			item.date = ((systemTime.wYear-1980)<<9)|((systemTime.wMonth&15)<<5)|(systemTime.wDay&31);
			item.size = file->size;

			// ɾ����ǰ��������¼
			vector<unsigned short> availableSector; 
			availableSector.push_back(item.startingSector);
			for (;;)
			{
				unsigned short num=0;
				vhd.seekg(BLOCK_SIZE+2*availableSector.back());
				vhd.read((char*)&num, 2);
				// ɾ��FAT
				vhd.seekp(BLOCK_SIZE+2*availableSector.back());
				vhd.write("\0\0", 2);
				// ɾ��FAT����
				vhd.seekp((1+FAT_SIZE)*BLOCK_SIZE+2*availableSector.back());
				vhd.write("\0\0", 2);
				if (num != (unsigned short)0xffff)
				{
					availableSector.push_back(num);
				}
				else
				{
					break;
				}
			}

			if (writeNewFile(&item, positionForFile, file->content) == true)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
	}
}

bool VirtualDisk::deleteFile(string& fileName)
{
	CatalogItem item;
	int i;
	int positionForFile;
	string name,extension;
	if ((getName(name, fileName) != true) || (getExtension(extension, fileName)) != true)
	{
		cout << "Bad file name" << endl;
		return false;
	}
	// �����ļ��Ƿ����
	for (i=CATALOG_OFFSET*BLOCK_SIZE; i<(CATALOG_OFFSET+32)*BLOCK_SIZE; i+=sizeof(CatalogItem)) 
	{
		vhd.seekg(i);
		vhd.read((char*)&item, sizeof(CatalogItem));
		if ((strcmp_v(item.name, name.c_str(), 8)==true) && (strcmp_v(item.extension, extension.c_str(), 3))==true)
		{
			positionForFile = i;
			break;
		}
	}
	// �ļ�������
	if (i >= (CATALOG_OFFSET+32)*BLOCK_SIZE)
	{
		cout << "Cannot find the file" << endl;
		return false;
	}
	else
	{
		// ɾ����ǰ��������¼
		vector<unsigned short> sectorsForFile; 
		sectorsForFile.push_back(item.startingSector);
		for (;;)
		{
			unsigned short num=0;
			vhd.seekg(BLOCK_SIZE+2*sectorsForFile.back());
			vhd.read((char*)&num, 2);
			// ɾ��FAT
			vhd.seekp(BLOCK_SIZE+2*sectorsForFile.back());
			vhd.write("\0\0", 2);
			// ɾ��FAT����
			vhd.seekp((1+FAT_SIZE)*BLOCK_SIZE+2*sectorsForFile.back());
			vhd.write("\0\0", 2);
			if (num != (unsigned short)0xffff)
			{
				sectorsForFile.push_back(num);
			}
			else
			{
				break;
			}
		}
		// ɾ��Ŀ¼
		vhd.seekp(positionForFile);
		vhd.write("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 32);
		vhd.flush();
		return true;
	}
}


bool VirtualDisk::writeNewFile(CatalogItem* item, const int positionForFile, const char* content)
{
	// Ѱ�ҿ��õ�����
	vector<unsigned short> availableSector; 
	for (unsigned short i = 4; i < FAT_SIZE*BLOCK_SIZE; i+=2)
	{
		vhd.seekg(BLOCK_SIZE+i);
		unsigned short num;
		vhd.read((char*)&num, 2);
		if (num == 0)// ��������
		{
			availableSector.push_back(i/2);// ����������
			if (availableSector.size() > static_cast<unsigned int>(item->size/BLOCK_SIZE))
			{
				break;
			}
		}
	}

	if (availableSector.size() <= static_cast<unsigned int>(item->size/BLOCK_SIZE))
	{
		cout << "Disk is full!" << endl;
		return false;
	}
	else
	{
		item->startingSector = availableSector[0];
		// ��Ŀ¼д��
		vhd.seekp(positionForFile);
		vhd.write((char*)item, 32);

		// дFAT�Լ�����
		for (unsigned int i=0; i<availableSector.size(); i++)
		{
			if (i < availableSector.size()-1)
			{
				// дFAT
				vhd.seekp(BLOCK_SIZE+2*availableSector[i]);
				vhd.write((char*)&availableSector[i+1], 2);
				// дFAT����
				vhd.seekp(BLOCK_SIZE*(FAT_SIZE+1)+2*availableSector[i]);
				vhd.write((char*)&availableSector[i+1], 2);
				// д�ļ�����
				vhd.seekp((DATA_OFFSET+availableSector[i]-2)*BLOCK_SIZE);
				vhd.write(content+i*BLOCK_SIZE, BLOCK_SIZE);
			}
			// ���һ��������Ҫ��������
			else
			{
				// дFAT
				vhd.seekp(BLOCK_SIZE+2*availableSector[i]);
				vhd.write("\377\377", 2); //д��0xffff
				// дFAT����
				vhd.seekp(BLOCK_SIZE*(FAT_SIZE+1)+2*availableSector[i]);
				vhd.write("\377\377", 2); //д��0xffff
				// д�ļ�����
				vhd.seekp((DATA_OFFSET+availableSector[i]-2)*BLOCK_SIZE);
				vhd.write(content+i*BLOCK_SIZE, item->size%BLOCK_SIZE);
			}
		}
		vhd.flush();
		return true;
	}
}

bool VirtualDisk::strcmp_v(const char* str1, const char* str2, int size)
{
	int i;
	for (i = 0; i < size; i++)
	{
		if (str1[i]=='\0' && str2[i]=='\0')
		{
			return true;
		}
		else if (str1[i]=='\0' && str2[i]!='\0')
		{
			return false;
		}
		else if (str1[i]!='\0' && str2[i]=='\0')
		{
			return false;
		}
		else if (str1[i]-str2[i] != 0)
		{
			return false;
		}
	}
	return true;
}

void VirtualDisk::strcpy_v(char* dst, const char* src, int size)
{
	int i;
	for (i=0; i<size; i++)
	{
		dst[i] = src[i];
		if (src[i]=='\0')
		{
			break;
		}
	}
	// ����'\0'֮�����Ĳ���ȫ����0
	for (; i<size; i++)
	{
		dst[i] = '\0';
	}
}

bool VirtualDisk::getName(string& fileName, string& str)
{
	size_t pos = str.find_first_of('.');
	if (pos == string::npos)
	{
		return false;
	}
	fileName = str.substr(0, pos);
	if (fileName.size() > 8)
	{
		return false;
	}
	else
	{
		// ����дת��ΪСд
		transform(fileName.begin(), fileName.end(), fileName.begin(), tolower);
		// �ļ���ֻ������ĸ�����»������
		for (unsigned int i=0; i<fileName.size(); i++)
		{
			if (!(fileName[i]>='a'&&fileName[i]<='z')
				&& !(fileName[i]>='0'&&fileName[i]<='9')
				&& fileName[i]!='_')
			{
				return false;
			}
		}
		return true;
	}
}

bool VirtualDisk::getExtension(string& extension, string& str)
{
	size_t pos = str.find_first_of('.');
	if (pos == string::npos)
	{
		return false;
	}
	extension = str.substr(pos+1, string::npos);
	if (extension.size() > 3)
	{
		return false;
	}
	else
	{
		// ����дת��ΪСд
		transform(extension.begin(), extension.end(), extension.begin(), tolower);
		// �ļ���չ��ֻ������ĸ���
		for (unsigned int i=0; i<extension.size(); i++)
		{
			if (!(extension[i]>='a' && extension[i]<='z'))
			{
				return false;
			}
		}
		return true;
	}
}

void VirtualDisk::dir()
{
	CatalogItem item;
	// �����ļ��Ƿ����
	cout << "Filename        Type        Size        Timestamp        " << endl;
	for (auto i=CATALOG_OFFSET*BLOCK_SIZE; i<(CATALOG_OFFSET+32)*BLOCK_SIZE; i+=sizeof(CatalogItem)) 
	{
		vhd.seekg(i);
		vhd.read((char*)&item, sizeof(CatalogItem));
		if (strcmp_v(item.name,"", 3) == false)
		{
			// �����ļ������
			if (item.nature == FILE_HIDDEN)
			{
				continue;
			}
			// ����ļ���
			char name[9], extension[4];
			strcpy_v(name, item.name, 8);
			name[8] = '\0';
			strcpy_v(extension, item.extension, 3);
			extension[3] = '\0';
			printf("%s.%s", name, extension);
			int blank = 15-strlen(name)-strlen(extension);
			for (auto i=0; i<blank; i++)
			{
				printf(" ");
			}
			// ����ļ�����
			switch (item.nature)
			{
			case FILE_READONLY:
				printf("Read-only");
				blank = 12-strlen("Read-only");
				for (auto i=0; i<blank; i++)
				{
					printf(" ");
				}
				break;
			case FILE_READWRITE:
				printf("Read-Write");
				blank = 12-strlen("Read-Write");
				for (auto i=0; i<blank; i++)
				{
					printf(" ");
				}
				break;
			case FILE_SYSTEM:
				printf("System");
				blank = 12-strlen("System");
				for (auto i=0; i<blank; i++)
				{
					printf(" ");
				}
				break;
			case FILE_SUB_DIR:
				printf("Subdir");
				blank = 12-strlen("Subdir");
				for (auto i=0; i<blank; i++)
				{
					printf(" ");
				}
				break;
			default:
				for (auto i=0; i<12; i++)
				{
					printf(" ");
				}
				break;
			}
			// ����ļ���С
			printf("%d", item.size);
			blank = item.size;
			for (auto i=0; i<12; i++)
			{
				if (blank !=0)
				{
					blank /= 10;
				}
				else
				{
					printf(" ");
				}
			}
			// ����ļ��޸�ʱ��
			unsigned int hour, minute, second, year, month, day;
			hour = (item.time & 0xf800) >> 11;
			minute = (item.time & 0x07e0) >> 5;
			second = (item.time & 0x001f) << 1;
			year = ((item.date & 0xfe00) >> 9) + 1980;
			month = (item.date & 0x01e0) >> 5;
			day = item.date & 0x001f;
			printf("%d/%d/%d %d:%d:%d", year, month, day, hour, minute, second);
			printf("\n");
		}
	}
}

void VirtualDisk::rename(string& oldName, string& newName)
{
	CatalogItem item;
	string name, extension;
	if (getName(name, oldName) == false
		|| getExtension(extension, oldName) == false)
	{
		cout << "bad file name" << endl;
		return;
	}
	// �����ļ��Ƿ����
	for (auto i=CATALOG_OFFSET*BLOCK_SIZE; i<(CATALOG_OFFSET+32)*BLOCK_SIZE; i+=sizeof(CatalogItem)) 
	{
		vhd.seekg(i);
		vhd.read((char*)&item, sizeof(CatalogItem));
		if (strcmp_v(name.c_str(), item.name, 8) == true
			&& strcmp_v(extension.c_str(), item.extension, 3) == true)
		{
			if (getName(name, newName) == false
				|| getExtension(extension, newName) == false)
			{
				cout << "bad file name" << endl;
				return;
			}
			strcpy_v(item.name, name.c_str(), 8);
			strcpy_v(item.extension, extension.c_str(), 3);
			SYSTEMTIME systemTime;
			GetLocalTime(&systemTime);
			item.time = (systemTime.wHour<<11)|((systemTime.wMinute&63)<<5)|((systemTime.wSecond&63)>>1);
			item.date = ((systemTime.wYear-1980)<<9)|((systemTime.wMonth&15)<<5)|(systemTime.wDay&31);
			vhd.seekp(i);
			vhd.write((char*)&item, sizeof(CatalogItem));
			vhd.flush();
			cout << "Rename complete" << endl;
			return;
		}
	}
	cout << "No such file: " << oldName << endl;
}

void VirtualDisk::copy(string& oldName, string& newName)
{
	File* tempFile;
	string name, extension;
	if (getName(name, newName) == false
		|| getExtension(extension, newName) == false)
	{
		cout << "bad file name" << endl;
		return;
	}

	CatalogItem item;
	// �����ļ��Ƿ����
	for (auto i = CATALOG_OFFSET*BLOCK_SIZE; i<(CATALOG_OFFSET + 32)*BLOCK_SIZE; i += sizeof(CatalogItem))
	{
		vhd.seekg(i);
		vhd.read((char*)&item, sizeof(CatalogItem));
		if (strcmp_v(name.c_str(), item.name, 8) == true
			&& strcmp_v(extension.c_str(), item.extension, 3) == true)
		{
			cout << "file " << newName << " has been existed" << endl;
			return;
		}
	}
	tempFile = read(oldName);
	if (tempFile == nullptr)
	{
		return;
	}
	strcpy_v(tempFile->name, name.c_str(), 8);
	strcpy_v(tempFile->extension, extension.c_str(), 3);
	if (write(tempFile) == true)
	{
		cout << "copy complete" << endl;
	}
	else
	{
		cout << "copy fails" << endl;
	}
}

void VirtualDisk::readSection(unsigned short number, char* data)
{
	vhd.seekg(number*BLOCK_SIZE);
	vhd.read(data, BLOCK_SIZE);
}

void VirtualDisk::writeSection(unsigned short number, char* data)
{
	vhd.seekp(number*BLOCK_SIZE);
	vhd.write(data, BLOCK_SIZE);
	vhd.flush();
}