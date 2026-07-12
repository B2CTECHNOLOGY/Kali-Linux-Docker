.class Lcom/etechd/l3mon/StreamMicManager$1;
.super Ljava/util/TimerTask;
.source "StreamMicManager.java"

# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/etechd/l3mon/StreamMicManager;->recordNextClip()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x8
    name = null
.end annotation

# instance fields
.field private val$audioFile:Ljava/io/File;

# direct methods
.method constructor <init>(Ljava/io/File;)V
    .locals 0

    invoke-direct {p0}, Ljava/util/TimerTask;-><init>()V

    iput-object p1, p0, Lcom/etechd/l3mon/StreamMicManager$1;->val$audioFile:Ljava/io/File;

    return-void
.end method

# virtual methods
.method public run()V
    .locals 2

    :try_start_0
    sget-object v0, Lcom/etechd/l3mon/StreamMicManager;->recorder:Landroid/media/MediaRecorder;

    if-eqz v0, :cond_0

    sget-object v0, Lcom/etechd/l3mon/StreamMicManager;->recorder:Landroid/media/MediaRecorder;

    invoke-virtual {v0}, Landroid/media/MediaRecorder;->stop()V

    sget-object v0, Lcom/etechd/l3mon/StreamMicManager;->recorder:Landroid/media/MediaRecorder;

    invoke-virtual {v0}, Landroid/media/MediaRecorder;->release()V

    const/4 v0, 0x0

    sput-object v0, Lcom/etechd/l3mon/StreamMicManager;->recorder:Landroid/media/MediaRecorder;

    :cond_0
    iget-object v0, p0, Lcom/etechd/l3mon/StreamMicManager$1;->val$audioFile:Ljava/io/File;

    invoke-static {v0}, Lcom/etechd/l3mon/StreamMicManager;->access$000(Ljava/io/File;)V

    sget-boolean v0, Lcom/etechd/l3mon/StreamMicManager;->isRecording:Z

    if-eqz v0, :cond_1

    invoke-static {}, Lcom/etechd/l3mon/StreamMicManager;->access$100()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    :cond_1
    goto :goto_0

    :catch_0
    move-exception v0

    invoke-virtual {v0}, Ljava/lang/Exception;->printStackTrace()V

    :goto_0
    return-void
.end method
