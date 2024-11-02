#!/bin/bash

# 启动/重启 Grass 的函数（选项 1）
turn_on_grass() {
    # 提示用户输入 Grass 访问令牌和刷新令牌
    read -p "Grass 访问令牌: " grass_access
    read -p "Grass 刷新令牌: " grass_refresh

    # 如果 secrets.json 不存在，则创建它
    if [ ! -f secrets.json ]; then
        echo "{}" > secrets.json
    fi

    # 使用 Grass 令牌更新 secrets.json
    jq --arg access "$grass_access" --arg refresh "$grass_refresh" '. + {grass_access: $access, grass_refresh: $refresh}' secrets.json > temp.json && mv temp.json secrets.json

    # 从 secrets.json 读取令牌
    grass_access=$(jq -r '.grass_access' secrets.json)
    grass_refresh=$(jq -r '.grass_refresh' secrets.json)

    # 检查令牌是否正确设置
    if [ -z "$grass_access" ] || [ -z "$grass_refresh" ]; then
        echo "错误: Grass 令牌未正确设置。"
        return
    fi

    # 使用 Grass 令牌配置 PINGPONG
    ./PINGPONG config set --grass.access="$grass_access" --grass.refresh="$grass_refresh"

    # 重启 Grass 依赖
    ./PINGPONG stop --depins=grass
    ./PINGPONG start --depins=grass

    echo "Grass 已配置并重启。"
}

# 主菜单函数
show_menu() {
    echo "请选择一个选项:"
    echo "1) 启动（重启）Grass"
    echo "2) 退出"
    read -p "输入你的选择 [1-2]: " choice

    case $choice in
        1)
            turn_on_grass
            ;;
        2)
            echo "正在退出..."
            exit 0
            ;;
        *)
            echo "无效的选择!"
            show_menu
            ;;
    esac
}

# 运行菜单
show_menu
