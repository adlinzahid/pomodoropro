void main() {
  List<int> numbers = []; //integer values only
  numbers.add(5); //insert new value at the end of the list
  numbers.insert(1, 4); //insert at position 1, value 4
  print(numbers); //print the whole list.
  for (int number in numbers) {
    //print each value in the list
    print(number);
  }
}
