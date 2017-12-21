#include "DiamondSquare.h"

float DiamondSquare::getRnd(float a, float b) {
	return a + ((float) rand() / RAND_MAX) * (b - a);
}

float DiamondSquare::map(float value, float minIn, float maxIn, float minOut, float maxOut) {
	return (value - minIn) / (maxIn - minIn) * (maxOut - minOut) + minOut;
}

void DiamondSquare::square(int step) {
	int half = step / 2;

	for (int i = 0; i < size - 1; i += step) {
		for (int j = 0; j < size - 1; j += step) {
			float avg = (field[i][j] + field[i + step][j] + field[i][j + step] + field[i + step][j + step]) / 4;

			field[i + half][j + half] = avg + R * getRnd(-step, step);
			field[i + half][j + half] = field[i + half][j + half] > maxHeight ? maxHeight : field[i + half][j + half];
		}
	}
}

void DiamondSquare::diamond(int step) {
	int half = step / 2;

	for (int i = 0; i < size - 1; i += half) {
		for (int j = (i + half) % step; j < size - 1; j += step) {
			int left = i - half < 0 ? size - 1 : i - half;
			int right = i + half > size - 1 ? 0 : i + half;
			
			int top = j - half < 0 ? size - 1 : j - half;
			int bottom = j + half > size - 1 ? 0 : j + half;

			float avg = (field[left][j] + field[right][j] + field[i][top] + field[i][bottom]) / 4;

			field[i][j] = avg + R * getRnd(-step, step);
			field[i][j] = field[i][j] > maxHeight ? maxHeight : field[i][j];
		}
	}
}

void DiamondSquare::smooth() {
	std::vector<std::vector<float>> tmp(field);

	for (int i = 1; i < size - 1; i++) 
		for (int j = 1; j < size - 1; j++) 
			field[i][j] = (tmp[i - 1][j - 1] + tmp[i - 1][j] + tmp[i - 1][j + 1] + tmp[i][j - 1] + tmp[i][j] + tmp[i][j + 1] + tmp[i + 1][j - 1] + tmp[i + 1][j] + tmp[i + 1][j + 1]) / 9.0;
}

void DiamondSquare::normalize() {
	smooth();

	min = max = fabs(field[0][0]);

	for (int i = 0; i < size; i++) {
		for (int j = 0; j < size; j++) {
			field[i][j] = field[i][j] * field[i][j];

			if (min > field[i][j])
				min = field[i][j];

			if (max < field[i][j])
				max = field[i][j];
		}
	}

	for (int i = 0; i < size; i++)
		for (int j = 0; j < size; j++)
			field[i][j] = map(field[i][j], min, max, min, maxHeight);

	for (int i = 0; i < size; i++)
		field[i][0] = field[i][size - 1];

	for (int i = 0; i < size; i++)
		field[0][i] = field[size - 1][i];
}

DiamondSquare::DiamondSquare(int rows, int cols, float R, float maxHeight) {
	int n = log2(std::max(rows, cols)) + 1; // least power of two

	this->size = 1 + (1 << n); // 2^n+1
	this->R = R;
	this->maxHeight = maxHeight;

	field = std::vector<std::vector<float>>(size, std::vector<float>(size, 0.0f));

	srand(time(NULL));

	/*field[0][0] = getRnd(0, 50);
	field[0][size - 1] = getRnd(0, 50);
	field[size - 1][0] = getRnd(0, 50);
	field[size - 1][size - 1] = getRnd(0, 50);*/

	field[0][0] = field[size - 1][0] = field[0][size - 1] = field[size - 1][size - 1] = 0;
}

void DiamondSquare::start() {
	int step = size - 1;

	while (step > 1) {
		square(step);
		diamond(step);

		step /= 2;
	}

	normalize();
}

float DiamondSquare::operator()(int i, int j) const {
	return field[i][j];
}

int DiamondSquare::getSize() const {
	return size;
}