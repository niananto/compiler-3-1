#include<bits/stdc++.h>

using namespace std;

int main() {
    int b = 10;
    int* a = &b;

    vector<int*> v;
    v.push_back(a);

    cout << *a << endl;
}