#!/usr/bin/env python3
import os
import sys
from datetime import datetime

def merge_files(source_dirs, output_file, file_types):
    """
    合并多个指定目录下的指定类型文件到一个输出文件
    
    Args:
        source_dirs (list): 源代码目录路径的列表
        output_file (str): 输出文件的路径
        file_types (list): 要合并的文件类型列表，如 ['.c', '.h']
    """
    try:
        # 检查是否提供了源目录
        if not source_dirs:
            raise ValueError("没有提供源目录")

        # 验证每个源目录并收集目标文件
        target_files = []
        valid_dirs = []
        for source_dir in source_dirs:
            if not os.path.exists(source_dir):
                print(f"警告: 目录不存在: {source_dir}，将跳过此目录")
                continue
            valid_dirs.append(source_dir)
            for root, _, files in os.walk(source_dir):
                for file in files:
                    if any(file.endswith(ext) for ext in file_types):
                        target_files.append((source_dir, os.path.join(root, file)))
        
        # 如果没有找到任何文件
        if not target_files:
            print(f"警告: 未在提供的目录中找到以下类型的文件: {', '.join(file_types)}")
            return False
            
        # 创建输出文件
        with open(output_file, 'w', encoding='utf-8') as outfile:
            # 写入文件头部信息
            outfile.write(f"// 合并的源代码文件\n")
            outfile.write(f"// 生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            outfile.write(f"// 源目录: {', '.join(valid_dirs)}\n")
            outfile.write(f"// 文件类型: {', '.join(file_types)}\n\n")
            
            # 合并所有文件
            for source_dir, file_path in sorted(target_files, key=lambda x: x[1]):
                try:
                    with open(file_path, 'r', encoding='utf-8') as infile:
                        content = infile.read()
                    
                    # 计算相对路径并写入文件分隔符
                    rel_path = os.path.relpath(file_path, source_dir)
                    outfile.write(f"\n// ========================= From {source_dir}: {rel_path} =========================\n\n")
                    outfile.write(content)
                    outfile.write("\n")
                    print(f"已处理: {file_path}")
                    
                except Exception as e:
                    print(f"警告: 处理文件 {file_path} 时出错: {str(e)}")
                    continue
            
        print(f"\n成功合并了 {len(target_files)} 个文件到: {output_file}")
        
    except Exception as e:
        print(f"错误: {str(e)}")
        return False
        
    return True

def get_source_dirs():
    """获取用户输入的源目录列表"""
    while True:
        dirs_input = input("请输入源目录（用逗号分隔，如: dir1,dir2）：").strip()
        if not dirs_input:
            print("没有提供目录。请至少输入一个目录。")
            continue
        
        # 处理用户输入的目录
        source_dirs = [d.strip() for d in dirs_input.split(',')]
        # 检查每个目录是否存在
        invalid_dirs = [d for d in source_dirs if not os.path.exists(d)]
        if invalid_dirs:
            print(f"以下目录不存在，请输入有效目录：{', '.join(invalid_dirs)}")
            continue
        return source_dirs

def get_file_types():
    """获取用户输入的文件类型列表"""
    while True:
        types_input = input("请输入要合并的文件类型（用逗号分隔，如: .c,.h）：").strip()
        if not types_input:
            print("请至少输入一个文件类型！")
            continue
            
        # 处理用户输入的文件类型
        file_types = [t.strip() for t in types_input.split(',')]
        # 确保每个类型都以.开头
        file_types = [t if t.startswith('.') else f'.{t}' for t in file_types]
        return file_types

def main():
    # 获取脚本所在目录
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # 获取用户输入的源目录
    source_dirs = ['Sources'] # get_source_dirs()
    # 将相对路径转换为绝对路径，确保正确解析
    source_dirs = [os.path.join(script_dir, d) for d in source_dirs]
    
    # 获取桌面路径
    desktop = os.path.join(os.path.expanduser("~"), "Desktop")
    
    # 设置输出文件路径
    output_file = os.path.join(desktop, "merged_visual_debugger.txt")
    
    # 获取要合并的文件类型
    file_types = ['.swift'] #get_file_types()  # 默认可改为 ['.swift']，这里改为用户输入
    print(f"\n将合并以下类型的文件: {', '.join(file_types)}")
    print(f"源目录: {', '.join(source_dirs)}")
    
    # 执行合并
    success = merge_files(source_dirs, output_file, file_types)
    
    # 显示结果并等待用户确认
    if success:
        print("\n合并完成!")
    else:
        print("\n合并失败!")
    
    print("\n按Enter键退出...")
    input()

if __name__ == "__main__":
    main()
