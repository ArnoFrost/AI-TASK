# [排查] Cocos3D 模块 CocosActivity 找不到符号问题分析

> 创建时间: 2026-02-03 18:58
> 状态: 🔄 进行中

## 📋 问题描述

```
/Users/xuxin/Desktop/Work/Project/TencetVideoKMM/androidApp/cocos3d-demo/src/main/java/com/tencent/qqlive/cocos3d/Cocos3DDemoActivity.java:18: 
错误: 找不到符号
import com.cocos.lib.CocosActivity;
```

## 🔍 问题分析

### 1. 代码引用分析

[Cocos3DDemoActivity.java](/Users/xuxin/Desktop/Work/Project/TencetVideoKMM/androidApp/cocos3d-demo/src/main/java/com/tencent/qqlive/cocos3d/Cocos3DDemoActivity.java) 需要：
- `com.cocos.lib.CocosActivity` - Cocos 引擎的 Activity 基类
- `com.cocos.service.SDKWrapper` - Cocos 生命周期管理

### 2. 依赖来源分析

| 尝试的依赖来源 | 包含 CocosActivity？ | 包含 SDKWrapper？ | 问题 |
|---------------|---------------------|------------------|------|
| `buildDeps.magicDanmaku` (弹幕SDK) | ❌ **没有** | ❌ **没有** | 弹幕 SDK 是定制版，只有渲染组件 |
| `libcocos.jar` (从 Demo 提取) | ✅ 有 | ✅ 有 | 与弹幕 SDK 类冲突 (BuildConfig等) |

### 3. magic_danmaku_sdk 实际包含的类

```
com/cocos/lib/
├── CanvasRenderingContext2DImpl.java
├── CocosAudioFocusManager.java
├── CocosDownloader.java
├── CocosHandler.java
├── CocosHelper.java
├── CocosHttpURLConnection.java
├── CocosJavascriptJavaBridge.java
├── CocosKeyCodeHandler.java
├── CocosLocalStorage.java
├── CocosOrientationHelper.java
├── CocosPlayer.java              ⬅️ 弹幕使用这个
├── CocosReflectionHelper.java
├── CocosSensorHandler.java
├── CocosSurfaceView.java         ⬅️ 弹幕使用这个
├── CocosTouchHandler.java
├── CocosVideoHelper.java
├── CocosVideoView.java
├── CocosWebView.java
├── CocosWebViewHelper.java
├── GlobalObject.java
├── JsbBridge.java
├── JsbBridgeWrapper.java
├── SummaryStats.java
├── Utils.java
└── BuildConfig.java              ⬅️ 这个导致冲突
```

**关键发现：弹幕 SDK 没有 `CocosActivity`！**

### 4. 现有弹幕模块接入方式

弹幕模块（magic-danmaku）使用的是 **组件化接入**，不是 **Activity 接入**：

```java
// 弹幕模块的使用方式 - 使用 CocosPlayer + CocosSurfaceView 组合
// 不需要继承 CocosActivity
public class CocosDebugActivity extends CommonActivity { // 普通 Activity
    // 使用 CocosPlayer 作为渲染组件
}
```

### 5. Cocos Creator 官方 Demo 接入方式

Cocos Creator 3.8.8 生成的 Android 项目使用的是 **Activity 接入**：

```java
// 官方 Demo 方式 - 继承 CocosActivity
import com.cocos.lib.CocosActivity;
import com.cocos.service.SDKWrapper;

public class AppActivity extends CocosActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        SDKWrapper.shared().init(this);
    }
}
```

需要的类：
- `com.cocos.lib.CocosActivity` (继承自 `GameActivity`)
- `com.cocos.service.SDKWrapper` (生命周期封装)

## 🏗️ 架构差异对比

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     腾讯视频弹幕模块 (magic-danmaku)                          │
├─────────────────────────────────────────────────────────────────────────────┤
│  定制化 magic_danmaku_sdk                                                   │
│  ├── CocosPlayer (自定义播放器组件)                                          │
│  ├── CocosSurfaceView (渲染视图)                                            │
│  └── 各种 Helper 类                                                         │
│  ⚠️ 没有 CocosActivity/SDKWrapper (因为不需要独立 Activity)                   │
├─────────────────────────────────────────────────────────────────────────────┤
│  使用方式：                                                                  │
│  - 在普通 Activity/Fragment 中嵌入 CocosPlayer                              │
│  - 作为弹幕渲染组件使用                                                       │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                     Cocos Creator 官方 Demo                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│  标准 libcocos.jar                                                         │
│  ├── CocosActivity (Activity 基类)                                         │
│  ├── SDKWrapper (生命周期管理)                                              │
│  ├── GameActivity (Google Android Games SDK)                               │
│  └── 完整的 com.cocos.lib 包                                               │
├─────────────────────────────────────────────────────────────────────────────┤
│  使用方式：                                                                  │
│  - 继承 CocosActivity 创建独立 Activity                                     │
│  - 全屏 3D 游戏/应用场景                                                     │
└─────────────────────────────────────────────────────────────────────────────┘
```

## ❓ 核心问题

**弹幕 SDK 和官方 Cocos 的 Java 层代码不兼容！**

| 类名 | 弹幕 SDK 版本 | 官方版本 | 冲突 |
|------|-------------|---------|-----|
| `BuildConfig` | ✅ 有 | ✅ 有 | ⚠️ 冲突 |
| `CocosActivity` | ❌ 没有 | ✅ 有 | - |
| `SDKWrapper` | ❌ 没有 | ✅ 有 | - |
| `CocosPlayer` | ✅ 有 | ❌ 没有 | - |

## 🛠️ 解决方案

### 方案一：组件化接入（推荐 ✅）

**参考弹幕模块的方式，使用 CocosPlayer + CocosSurfaceView**

优点：
- 与现有弹幕 SDK 兼容
- 可以作为 View 嵌入任意页面
- 不需要独立进程

缺点：
- 需要自己管理 Cocos 生命周期
- 需要研究 CocosPlayer 的 API

```java
// 方案一示例
public class Cocos3DDemoActivity extends AppCompatActivity {
    private CocosPlayer cocosPlayer;
    private CocosSurfaceView surfaceView;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // 使用 CocosPlayer 组件化方式
        cocosPlayer = new CocosPlayer();
        surfaceView = new CocosSurfaceView(this);
        // ...
    }
}
```

### 方案二：隔离 JAR 包（需要处理冲突）

**保留 libcocos.jar，但排除冲突的类**

步骤：
1. 解压 libcocos.jar
2. 删除冲突的类（如 BuildConfig）
3. 重新打包为 libcocos-stripped.jar

优点：
- 保持官方 Activity 接入方式
- 代码改动小

缺点：
- 维护成本高
- 可能有其他隐藏冲突

```bash
# 处理脚本
mkdir temp && cd temp
jar -xf ../libcocos.jar
rm -rf com/cocos/lib/BuildConfig.class
jar -cf ../libcocos-stripped.jar .
```

### 方案三：独立进程隔离（复杂）

**将 cocos3d-demo 完全独立运行在单独进程**

优点：
- 完全隔离，无类冲突
- 可以使用不同版本的 Cocos

缺点：
- 进程间通信复杂
- 需要处理 ClassLoader 隔离
- 性能开销

## 📝 推荐方案

### 推荐：方案二 - 隔离 JAR 包

理由：
1. 保持 Cocos Creator Demo 的标准接入方式
2. 后续可以方便地从 Cocos Creator 更新资源
3. 只需处理 `BuildConfig` 类冲突

### 实施步骤

1. **处理 libcocos.jar 冲突类**
   ```bash
   cd /path/to/cocos3d-demo/libs
   mkdir temp && cd temp
   jar -xf ../libcocos.jar
   rm -rf com/cocos/lib/BuildConfig.class
   rm -rf com/cocos/lib/BuildConfig*.class
   jar -cf ../libcocos-stripped.jar .
   rm -rf temp
   rm libcocos.jar
   ```

2. **修改 build.gradle**
   ```groovy
   dependencies {
       // 使用处理后的 JAR
       implementation files('libs/libcocos-stripped.jar')
       
       // 排除弹幕 SDK 中的 Cocos 类冲突
       implementation(buildDeps.magicDanmaku) {
           exclude group: 'com.cocos.lib', module: 'BuildConfig'
       }
   }
   ```

3. **验证编译**

## 🔗 相关文件

- [Cocos3DDemoActivity.java](/Users/xuxin/Desktop/Work/Project/TencetVideoKMM/androidApp/cocos3d-demo/src/main/java/com/tencent/qqlive/cocos3d/Cocos3DDemoActivity.java)
- [cocos3d-demo/build.gradle](/Users/xuxin/Desktop/Work/Project/TencetVideoKMM/androidApp/cocos3d-demo/build.gradle)
- [magic-danmaku/build.gradle](/Users/xuxin/Desktop/Work/Project/TencetVideoKMM/androidApp/danmu/magic-danmaku/build.gradle)

## 📋 下一步执行步骤

### Step 1: 处理 libcocos.jar（移除冲突类）

原始 JAR 已在 git 历史中找到，commit: `f2468c69`

```bash
# 从 git 恢复原始 JAR
cd /Users/xuxin/Desktop/Work/Project/TencetVideoKMM
git show f2468c69:androidApp/cocos3d-demo/libs/libcocos.jar > /tmp/libcocos.jar

# 处理 JAR（移除 BuildConfig）
mkdir -p /tmp/libcocos_temp && cd /tmp/libcocos_temp
unzip -q /tmp/libcocos.jar
rm -f com/cocos/lib/BuildConfig.class
jar -cf /Users/xuxin/Desktop/Work/Project/TencetVideoKMM/androidApp/cocos3d-demo/libs/libcocos-stripped.jar .
cd /tmp && rm -rf libcocos_temp libcocos.jar
```

### Step 2: 更新 build.gradle

```groovy
dependencies {
    // 使用处理后的 JAR（已移除 BuildConfig 避免冲突）
    implementation files('libs/libcocos-stripped.jar')
    
    // Google Games Activity - CocosActivity 继承自 GameActivity
    implementation 'androidx.games:games-activity:2.0.2'
    
    // AndroidX 依赖
    implementation 'androidx.core:core:1.10.1'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    
    // OkHttp
    implementation 'com.squareup.okhttp3:okhttp:3.12.6'
}
```

### Step 3: 验证

```bash
# 同步项目
./gradlew :androidApp:cocos3d-demo:compileDebugJavaWithJavac
```

## 📊 进度追踪

- [x] 获取原始 libcocos.jar 文件（git history: f2468c69）
- [x] 执行 JAR 处理脚本，移除 BuildConfig 冲突类
- [x] 恢复 SDKWrapper.java（git history: c7a69706）
- [x] 更新 build.gradle 配置
- [ ] 验证编译通过
- [ ] 验证运行时功能正常

## 🔧 已执行的修改

### 1. 创建处理后的 JAR 文件
```
libcocos-stripped.jar (151KB)
├── com/cocos/lib/CocosActivity.class ✅
├── com/cocos/lib/CocosActivity$1.class ✅
├── ... (其他 Cocos 辅助类)
└── BuildConfig.class ❌ (已移除，避免与弹幕 SDK 冲突)
```

### 2. 恢复 SDKWrapper.java
```
src/main/java/com/cocos/service/SDKWrapper.java (6.2KB)
```

### 3. 更新 build.gradle
```groovy
dependencies {
    // 使用处理后的 JAR（已移除 BuildConfig 避免冲突）
    implementation files('libs/libcocos-stripped.jar')
    
    // Google Games Activity
    implementation 'androidx.games:games-activity:2.0.2'
    
    // AndroidX 依赖
    implementation 'androidx.core:core:1.10.1'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    
    // OkHttp
    implementation 'com.squareup.okhttp3:okhttp:3.12.6'
}
```

## 📋 待验证

请在 Android Studio 中执行以下命令验证编译：

```bash
cd /Users/xuxin/Desktop/Work/Project/TencetVideoKMM/androidApp
./gradlew :cocos3d-demo:compileDebugJavaWithJavac
```
