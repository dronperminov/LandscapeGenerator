#include <iostream>
#include <vector>
#include <random>
#include <ctime>

class DiamondSquare {
	int size; // размер поля (2^n + 1)
	float R; // параметр для случайной величины
	float min; // минимальное значение высоты
	float max; // максимальное значение высоты
	float maxHeight;

	std::vector<std::vector<float>> field;

	float getRnd(float a, float b);
	float map(float value, float minIn, float maxIn, float minOut, float maxOut);

	void square(int step);
	void diamond(int step);

	void smooth();
	void normalize();

public:
	DiamondSquare(int rows, int cols, float R = 1.0f, float maxHeight = 10);
	void start();

	float operator()(int i, int j) const;
	int getSize() const;
};