// =====================================================================================
//
//       Filename:  stat.cc
//
//    Description:  
//
//        Version:  1.0
//        Created:  2015年10月10日 11时11分56秒
//       Revision:  none
//       Compiler:  g++
//
//         Author:  Jinkun Lin, jkunlin@gmail.com
//   Organization:  School of EECS, Peking University
//
// =====================================================================================

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <limits>

using namespace std;

class Director_entry {
public:
	Director_entry (string director_name) {
		string cmd = "ls " + director_name + " > " + director_name + "_tmpfile.txt";
		system(cmd.c_str());
		fstream file(director_name + "_tmpfile.txt");
		if (!file.is_open()) {
			cout << "can't open dir" << endl;
			exit(0);
		}
		string line;
		while (getline(file, line)) {
			file_name.push_back(line);
		}
		file.close();
		cmd = "rm " + director_name + "_tmpfile.txt";
		system(cmd.c_str());
	};

	vector<string>::const_iterator begin() {
		return file_name.begin();
	}

	vector<string>::const_iterator end() {
		return file_name.end();
	}

	vector<string>::size_type size() {
		return file_name.size();
	}

	using size_type = vector<string>::size_type;

	string& operator [] (size_type i) {
		return file_name[i];
	}

private:
	vector<string> file_name;
};

int main() {
	fstream simplification("simplification.xls", ios::out);
	if (!simplification.is_open()) {
		cout << "can't create simplification.xls" << endl;
		return 1;
	}
	simplification.precision(15);

	fstream solution("solution.xls", ios::out);
	if (!solution.is_open()) {
		cout << "can't create simplification.xls" << endl;
		return 1;
	}
	solution.precision(15);

	fstream sim_count("sim_count.xls", ios::out);
	if (!sim_count.is_open()) {
		cout << "can't create simplification.xls" << endl;
		return 1;
	}
	sim_count.precision(15);

	vector<string> all_benchmark_name = {"./bio", "./col", "./fb", "./inf",
		"./int", "./rec", "./ret", "./sci",
		"./soc", "./tec",  "./web"};

	for (auto benchmark_name : all_benchmark_name) {
		cout << "****  " << benchmark_name << "  ***" << endl;

		Director_entry benchmark(benchmark_name);
		for (auto instance_name : benchmark) {
			cout << instance_name << endl;

			long degree_1_count, degree_2_count, dominate_count, all_count;
			degree_1_count = degree_2_count = dominate_count = all_count = 0;

			double sum_vc_size = 0, sum_solve_time = 0;
			double min_vc_size = std::numeric_limits<double>::max();

			long origin_edge_size, origin_vertex_size;
			long simplified_edge_size, simplified_vertex_size;
			double sum_preprocess_time = 0;
			long fix_vertice_size;

			Director_entry instance(benchmark_name + "/" + instance_name);
			Director_entry::size_type i = 0;
			for (; i < instance.size(); ++i) {
				string result_file_name = instance[i];
//				cout << '\t' << result_file_name << endl;

				fstream result_file(benchmark_name + "/" + instance_name + "/" + result_file_name);
				if (!result_file.is_open()) {
					cout << "result file error" << endl;
					return 1;
				}

				double preprocess_time;
				double vc_size, solve_time;

				string line, tmp;
				istringstream is;

				//origin size
				getline(result_file, line);
				is.clear(); is.str(line);
				is >> tmp >> tmp >> tmp >> tmp >> tmp;
				is >> origin_vertex_size >> origin_edge_size;

//				//sim_count
//				getline(result_file, line);
//				is.clear(); is.str(line);
//				is >> degree_1_count >> degree_2_count >> dominate_count >> all_count;

				//simplified size
				getline(result_file, line);
				is.clear(); is.str(line);
				is >> tmp >> tmp >> tmp >> tmp >> tmp;
				is >> simplified_vertex_size >> simplified_edge_size;

				//preprocess time
				getline(result_file, line);
				is.clear(); is.str(line);
				is >> tmp >> tmp >> tmp >> tmp;
				is >> preprocess_time;
				sum_preprocess_time += preprocess_time;

				//fixed vertices size
				getline(result_file, line);
				is.clear(); is.str(line);
				is >> tmp >> tmp >> tmp >> tmp;
				is >> fix_vertice_size;

//				if (i == 0) {
//					simplification << instance_name << '\t';
//					simplification << origin_vertex_size << '\t';
//					simplification << origin_edge_size << '\t';
//					simplification << simplified_vertex_size << '\t';
//					simplification << simplified_edge_size << '\t';
//					simplification << fix_vertice_size << '\t';
//					simplification << preprocess_time << endl;
//				}
//
				//init_method
				getline(result_file, line);

				//initialize time
				getline(result_file, line);

				//initialize solution
				getline(result_file, line);

				//vertex cover size
				getline(result_file, line);
				is.clear(); is.str(line);
				is >> tmp >> tmp >> tmp >> tmp >> tmp >> tmp >> tmp;
				is >> vc_size;
				sum_vc_size += vc_size;
				if (vc_size < min_vc_size) {
					min_vc_size = vc_size;
				}

				//search step
				getline(result_file, line);

				//solve time
				getline(result_file, line);
				is.clear(); is.str(line);
				is >> tmp >> tmp >> tmp >> tmp >> tmp;
				is >> solve_time;
				sum_solve_time += solve_time;

				result_file.close();
			}
			simplification << instance_name << '\t';
			simplification << origin_vertex_size << '\t';
			simplification << origin_edge_size << '\t';
			simplification << simplified_vertex_size << '\t';
			simplification << simplified_edge_size << '\t';
			simplification << fix_vertice_size << '\t';
			simplification << sum_preprocess_time  / i << endl;

			solution << instance_name << '\t' << min_vc_size;
			solution << '(' << sum_vc_size / i << ')' << '\t';
			solution << sum_solve_time / i << endl;

			sim_count << instance_name << '\t' << degree_1_count << '\t';
			sim_count << degree_2_count << '\t' << dominate_count << '\t' << all_count;
			sim_count << endl;
		}
	}
	simplification.close();
	solution.close();
	sim_count.close();
	return 0;
}
