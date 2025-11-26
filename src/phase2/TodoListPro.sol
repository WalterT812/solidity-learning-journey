// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// 引入上面的文件
import "./Ownable.sol";

// [核心] "is" 关键字表示继承
// TodoListPro 现在拥有了 Ownable 的所有变量和函数！
contract TodoListPro is Ownable {
    
    struct Task {
        string name;
        bool isCompleted;
    }
    
    Task[] public tasks;

    // [核心] 使用 onlyOwner 修饰符
    // 效果：在执行这个函数前，先执行 Ownable 里的 onlyOwner 检查
    function createTask(string memory _name) public onlyOwner {
        tasks.push(Task(_name, false));
    }

    // 这个函数没加 onlyOwner，所以谁都能调
    function updateStatus(uint256 _index) public {
        Task storage todo = tasks[_index]; 
        todo.isCompleted = !todo.isCompleted;
    }
}