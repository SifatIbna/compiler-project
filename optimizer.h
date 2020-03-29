#include <bits/stdc++.h>
using namespace std;


string cmd(string line)
{
	int i = 0;
	while(line[i]!=' ') i++;
	return line.substr(0,i);
}


string dest(string line)
{
	int i=0;
	while(line[i]!=' ') i++;
	i++;
	int j = i + 1;
	while(line[j] != ',' && j<line.size()) j++;
	return line.substr(i, j-i);
}


string src(string line)
{
	int len = line.size();
	int i = 0;
	while(line[i] != ',') i++;
	i += 2;
	return line.substr(i, len-i);
}

// int main()
// {
// 	freopen("code.asm", "r", stdin);
// 	freopen("final.asm", "w", stdout);
//
// 	string buffer = "";
// 	string line = "";
//
//
// 	while(1)
// 	{
// 		getline(cin, line);
// 		if(line == "END MAIN") break;
//
// 		if(line == "") continue;
//
//
//
// 		if(cmd(line) == "ADD" || cmd(line) == "SUB")
// 		{
// 			if(src(line) == "0")
// 			{
// 				// do nothing
// 				continue;
// 			}
// 		}
//
//
// 		if(cmd(line) == "MUL" || cmd(line) == "DIV")
// 		{
// 			if(dest(line) == "1")
// 			{
// 				// do nothing
// 				continue;
// 			}
// 		}
//
// 		buffer = line;
// 		getline(cin, line);
//
// 		if(cmd(line) == "MOV" && cmd(buffer) == "MOV")
// 		{
// 			if(src(line) == dest(buffer) && src(buffer) == dest(line))
// 			{
// 				// discard new line
// 				cout << buffer << endl;
//
// 				continue;
// 			}
// 		}
//
//
//
//
//
//
// 		// no optimization
// 		// default action
//
// 		cout << buffer << endl;
// 		cout << line << endl;
//
//
//
//
// 		//cout << dest(line) << endl;
//
// 		return 0;
//
// 	}
//
//
// }
