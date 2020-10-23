package com.morbit.photogallery

import android.content.ContentUris
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import android.graphics.Bitmap
import java.io.ByteArrayOutputStream
import android.provider.MediaStore
import android.content.Context
import android.database.Cursor
import android.database.Cursor.FIELD_TYPE_INTEGER
import android.os.AsyncTask
import android.os.Build
import android.util.Size
import android.webkit.MimeTypeMap

/** PhotoGalleryPlugin */
class PhotoGalleryPlugin : FlutterPlugin, MethodCallHandler {
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "photo_gallery")
        val plugin = PhotoGalleryPlugin()
        plugin.context = flutterPluginBinding.applicationContext
        channel.setMethodCallHandler(plugin)
    }

    companion object {
        // This static function is optional and equivalent to onAttachedToEngine. It supports the old
        // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
        // plugin registration via this function while apps migrate to use the new Android APIs
        // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
        //
        // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
        // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
        // depending on the user's project. onAttachedToEngine or registerWith must both be defined
        // in the same class.
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "photo_gallery")
            val plugin = PhotoGalleryPlugin()
            plugin.context = registrar.activeContext()
            channel.setMethodCallHandler(plugin)
        }

        const val imageType = "image"
        const val videoType = "video"

        const val allAlbumId = "__ALL__"
        const val allAlbumName = "All"

        val imageMetadataProjection = arrayOf(
            MediaStore.Images.Media._ID,
            MediaStore.Images.Media.WIDTH,
            MediaStore.Images.Media.HEIGHT,
            MediaStore.Images.Media.DATE_TAKEN,
            MediaStore.Images.Media.DATE_MODIFIED
        )

        val videoMetadataProjection = arrayOf(
            MediaStore.Video.Media._ID,
            MediaStore.Video.Media.WIDTH,
            MediaStore.Video.Media.HEIGHT,
            MediaStore.Video.Media.DURATION,
            MediaStore.Video.Media.DATE_TAKEN,
            MediaStore.Video.Media.DATE_MODIFIED
        )

        const val imageOrderBy = "${MediaStore.Images.Media.DATE_TAKEN} DESC, ${MediaStore.Images.Media.DATE_MODIFIED} DESC"
        const val videoOrderBy = "${MediaStore.Video.Media.DATE_TAKEN} DESC, ${MediaStore.Video.Media.DATE_MODIFIED} DESC"
    }

    private var context: Context? = null

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "listAlbums" -> {
                val mediumType = call.argument<String>("mediumType")
                val mediumSubtype = call.argument<String>("mediumSubtype")
                BackgroundAsyncTask({
                    listAlbums(mediumType!!, mediumSubtype)
                }, { v ->
                    result.success(v)
                })
            }
            "listMedia" -> {
                val albumId = call.argument<String>("albumId")
                val mediumType = call.argument<String>("mediumType")
                val mediumSubtype = call.argument<String>("mediumSubtype")
                val total = call.argument<Int>("total")
                val skip = call.argument<Int>("skip")
                val take = call.argument<Int>("take")
                BackgroundAsyncTask({
                    when (mediumType) {
                        imageType -> listImages(albumId!!, total!!, skip, take, mediumSubtype)
                        videoType -> listVideos(albumId!!, total!!, skip, take, mediumSubtype)
                        else -> null
                    }
                }, { v ->
                    result.success(v)
                })
            }
            "getMedium" -> {
                val mediumId = call.argument<String>("mediumId")
                val mediumType = call.argument<String>("mediumType")
                BackgroundAsyncTask({
                    getMedium(mediumId!!, mediumType)
                }, { v ->
                    result.success(v)
                })
            }
            "getThumbnail" -> {
                val mediumId = call.argument<String>("mediumId")
                val mediumType = call.argument<String>("mediumType")
                val width = call.argument<Int>("width")
                val height = call.argument<Int>("height")
                BackgroundAsyncTask({
                    getThumbnail(mediumId!!, mediumType, width, height)
                }, { v ->
                    result.success(v)
                })
            }
            "getAlbumThumbnail" -> {
                val albumId = call.argument<String>("albumId")
                val mediumType = call.argument<String>("mediumType")
                val mediumSubtype = call.argument<String>("mediumSubtype")
                val width = call.argument<Int>("width")
                val height = call.argument<Int>("height")
                BackgroundAsyncTask({
                    getAlbumThumbnail(albumId!!, mediumType, mediumSubtype, width, height)
                }, { v ->
                    result.success(v)
                })
            }
            "getFile" -> {
                val mediumId = call.argument<String>("mediumId")
                val mediumType = call.argument<String>("mediumType")
                BackgroundAsyncTask({
                    getFile(mediumId!!, mediumType)
                }, { v ->
                    result.success(v)
                })
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {

    }

    private fun listAlbums(mediumType: String, mediumSubtype: String?): List<Map<String, Any>> {
        return when (mediumType) {
            imageType -> {
                listImageAlbums(mediumSubtype)
            }
            videoType -> {
                listVideoAlbums(mediumSubtype)
            }
            else -> {
                listOf()
            }
        }
    }

    private fun listImageAlbums(mediumSubtype: String?): List<Map<String, Any>> {

        val queryCondition = generateAlbumQueryCondition(mediumSubtype, MediaStore.Images.Media.MIME_TYPE)
        val selectionConditions = queryCondition[0]
        val selection = if (selectionConditions.count() > 0) selectionConditions.joinToString(separator = " AND ") else null
        val selectionArgs = queryCondition[1].toTypedArray()
        this.context?.run {
            var total = 0
            val albumHashMap = mutableMapOf<String, MutableMap<String, Any>>()

            val imageProjection = arrayOf(
                MediaStore.Images.Media.BUCKET_DISPLAY_NAME,
                MediaStore.Images.Media.BUCKET_ID
            )

            val imageCursor = this.contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                imageProjection,
                selection,
                selectionArgs,
                null
            )

            imageCursor?.use { cursor ->
                val bucketColumn = cursor.getColumnIndex(MediaStore.Images.Media.BUCKET_DISPLAY_NAME)
                val bucketColumnId = cursor.getColumnIndex(MediaStore.Images.Media.BUCKET_ID)

                while (cursor.moveToNext()) {
                    val bucketId = cursor.getString(bucketColumnId)
                    val album = albumHashMap[bucketId]
                    if (album == null) {
                        val folderName = cursor.getString(bucketColumn)
                        albumHashMap[bucketId] = mutableMapOf(
                            "id" to bucketId,
                            "mediumType" to imageType,
                            "mediumSubtype" to (mediumSubtype ?: ""),
                            "name" to folderName,
                            "count" to 1
                        )
                    } else {
                        val count = album["count"] as Int
                        album["count"] = count + 1
                    }
                    total++
                }
            }

            val albumList = mutableListOf<Map<String, Any>>()
            albumList.add(
                mapOf(
                    "id" to allAlbumId,
                    "mediumType" to imageType,
                    "mediumSubtype" to (mediumSubtype ?: ""),
                    "name" to allAlbumName,
                    "count" to total
                )
            )
            albumList.addAll(albumHashMap.values)
            return albumList
        }
        return listOf()
    }

    private fun listVideoAlbums(mediumSubtype: String?): List<Map<String, Any>> {

        val queryCondition = generateAlbumQueryCondition(mediumSubtype, MediaStore.Video.Media.MIME_TYPE)
        val selectionConditions = queryCondition[0]
        val selection = if (selectionConditions.count() > 0) selectionConditions.joinToString(separator = " AND ") else null
        val selectionArgs = queryCondition[1].toTypedArray()

        this.context?.run {
            var total = 0
            val albumHashMap = mutableMapOf<String, MutableMap<String, Any>>()

            val videoProjection = arrayOf(
                MediaStore.Video.Media.BUCKET_DISPLAY_NAME,
                MediaStore.Video.Media.BUCKET_ID
            )

            val videoCursor = this.contentResolver.query(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                videoProjection,
                selection,
                selectionArgs,
                null
            )

            videoCursor?.use { cursor ->
                val bucketColumn = cursor.getColumnIndex(MediaStore.Video.Media.BUCKET_DISPLAY_NAME)
                val bucketColumnId = cursor.getColumnIndex(MediaStore.Video.Media.BUCKET_ID)

                while (cursor.moveToNext()) {
                    val bucketId = cursor.getString(bucketColumnId)
                    val album = albumHashMap[bucketId]
                    if (album == null) {
                        val folderName = cursor.getString(bucketColumn)
                        albumHashMap[bucketId] = mutableMapOf(
                            "id" to bucketId,
                            "mediumType" to videoType,
                            "mediumSubtype" to (mediumSubtype ?: ""),
                            "name" to folderName,
                            "count" to 1
                        )
                    } else {
                        val count = album["count"] as Int
                        album["count"] = count + 1
                    }
                    total++
                }
            }

            val albumList = mutableListOf<Map<String, Any>>()
            albumList.add(mapOf(
                "id" to allAlbumId,
                "mediumType" to videoType,
                "mediumSubtype" to (mediumSubtype ?: ""),
                "name" to allAlbumName,
                "count" to total))
            albumList.addAll(albumHashMap.values)
            return albumList
        }
        return listOf()
    }

    private fun generateAlbumQueryCondition(
                                        mediumSubtype: String?,
                                        mimeTypeKey : String = MediaStore.Images.Media.MIME_TYPE): Array<MutableList<String>>  {
        var selectionConditions = mutableListOf<String>()
        var selectionArgs = mutableListOf<String>()
        if (mediumSubtype != null) {
            val mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(mediumSubtype)
            if (mimeType != null) {
                selectionConditions.add(element = "${mimeTypeKey} = ?")
                selectionArgs.add(element = mimeType)
            }
        }
        return arrayOf(selectionConditions, selectionArgs)
    }

    private fun listImages(albumId: String, total: Int, skip: Int?, take: Int?, mediumSubtype: String?): Map<String, Any> {
        val media = mutableListOf<Map<String, Any?>>()
        val offset = skip ?: 0
        val limit = take ?: (total - offset)

        val queryCondition = generateQueryCondition(albumId, MediaStore.Images.Media.BUCKET_ID,  mediumSubtype, MediaStore.Video.Media.MIME_TYPE)
        val selectionConditions = queryCondition[0]
        val selection = if (selectionConditions.count() > 0) selectionConditions.joinToString(separator = " AND ") else null
        val selectionArgs = queryCondition[1].toTypedArray()

        this.context?.run {
            val imageCursor = this.contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                imageMetadataProjection,
                selection,
                selectionArgs,
                "$imageOrderBy LIMIT $limit OFFSET $offset"
            )

            imageCursor?.use { cursor ->
                while (cursor.moveToNext()) {
                    media.add(getImageMetadata(cursor))
                }
            }
        }

        return mapOf(
            "start" to offset,
            "total" to total,
            "items" to media
        )
    }

    private fun listVideos(albumId: String, total: Int, skip: Int?, take: Int?, mediumSubtype: String?): Map<String, Any> {
        val media = mutableListOf<Map<String, Any?>>()
        val offset = skip ?: 0
        val limit = take ?: (total - offset)

        val queryCondition = generateQueryCondition(albumId, MediaStore.Video.Media.BUCKET_ID, mediumSubtype, MediaStore.Video.Media.MIME_TYPE)
        val selectionConditions = queryCondition[0]
        val selection = if (selectionConditions.count() > 0) selectionConditions.joinToString(separator = " AND ") else null
        val selectionArgs = queryCondition[1].toTypedArray()

        this.context?.run {
            val videoCursor = this.contentResolver.query(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                videoMetadataProjection,
                selection,
                selectionArgs,
                "$videoOrderBy LIMIT $limit OFFSET $offset")

            videoCursor?.use { cursor ->
                while (cursor.moveToNext()) {
                    media.add(getVideoMetadata(cursor))
                }
            }
        }

        return mapOf(
            "start" to offset,
            "total" to total,
            "items" to media
        )
    }

    private  fun generateQueryCondition(albumId: String,
                                        buckIDKey: String = MediaStore.Images.Media.BUCKET_ID,
                                        mediumSubtype: String?,
                                        mimeTypeKey : String = MediaStore.Images.Media.MIME_TYPE): Array<MutableList<String>>  {
        var selectionConditions = mutableListOf<String>()
        var selectionArgs = mutableListOf<String>()
        if (albumId != allAlbumId) {
            selectionConditions.add(element = "$buckIDKey = ?")
            selectionArgs.add(element = albumId)
        }
        if (mediumSubtype != null) {
            val mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(mediumSubtype)
            if (mimeType != null) {
                selectionConditions.add(element = "$mimeTypeKey = ?")
                selectionArgs.add(element = mimeType)
            }
        }
        return arrayOf(selectionConditions, selectionArgs)
    }

    private fun getMedium(mediumId: String, mediumType: String?): Map<String, Any?>? {
        return when (mediumType) {
            imageType -> {
                getImageMedia(mediumId)
            }
            videoType -> {
                getVideoMedia(mediumId)
            }
            else -> {
                getImageMedia(mediumId) ?: getVideoMedia(mediumId)
            }
        }
    }

    private fun getImageMedia(mediumId: String): Map<String, Any?>? {
        var imageMetadata: Map<String, Any?>? = null

        this.context?.run {
            val imageCursor = this.contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                imageMetadataProjection,
                "${MediaStore.Images.Media._ID} = $mediumId",
                null,
                null
            )

            imageCursor?.use { cursor ->
                if (cursor.moveToFirst()) {
                    imageMetadata = getImageMetadata(cursor)
                }
            }
        }

        return imageMetadata
    }

    private fun getVideoMedia(mediumId: String): Map<String, Any?>? {
        var videoMetadata: Map<String, Any?>? = null

        this.context?.run {
            val videoCursor = this.contentResolver.query(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                videoMetadataProjection,
                "${MediaStore.Images.Media._ID} = $mediumId",
                null,
                null)

            videoCursor?.use { cursor ->
                if (cursor.moveToFirst()) {
                    videoMetadata = getVideoMetadata(cursor)
                }
            }
        }

        return videoMetadata
    }

    private fun getThumbnail(mediumId: String, mediumType: String?, width: Int?, height: Int?): ByteArray? {
        return when (mediumType) {
            imageType -> {
                getImageThumbnail(mediumId, width, height)
            }
            videoType -> {
                getVideoThumbnail(mediumId, width, height)
            }
            else -> {
                getImageThumbnail(mediumId, width, height)
                    ?: getVideoThumbnail(mediumId, width, height)
            }
        }
    }

    private fun getImageThumbnail(mediumId: String, width: Int?, height: Int?): ByteArray? {
        var byteArray: ByteArray? = null

        val bitmap: Bitmap? = this.context?.run {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                try {
                    this.contentResolver.loadThumbnail(
                        ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, mediumId.toLong()),
                        Size(width ?: 72, height ?: 72),
                        null
                    )
                } catch (e: Exception) {
                    null
                }
            } else {
                MediaStore.Images.Thumbnails.getThumbnail(
                    this.contentResolver, mediumId.toLong(),
                    MediaStore.Images.Thumbnails.MINI_KIND,
                    null
                )
            }
        }
        bitmap?.run {
            ByteArrayOutputStream().use { stream ->
                this.compress(Bitmap.CompressFormat.JPEG, 100, stream)
                byteArray = stream.toByteArray()
            }
        }

        return byteArray
    }

    private fun getVideoThumbnail(mediumId: String, width: Int?, height: Int?): ByteArray? {
        var byteArray: ByteArray? = null

        val bitmap: Bitmap? = this.context?.run {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                try {
                    this.contentResolver.loadThumbnail(
                        ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, mediumId.toLong()),
                        Size(width ?: 72, height ?: 72),
                        null
                    )
                } catch (e: Exception) {
                    null
                }
            } else {
                MediaStore.Video.Thumbnails.getThumbnail(
                    this.contentResolver, mediumId.toLong(),
                    MediaStore.Images.Thumbnails.MINI_KIND,
                    null
                )
            }
        }
        bitmap?.run {
            ByteArrayOutputStream().use { stream ->
                this.compress(Bitmap.CompressFormat.JPEG, 100, stream)
                byteArray = stream.toByteArray()
            }
        }

        return byteArray
    }

    private fun getAlbumThumbnail(albumId: String, mediumType: String?, mediumSubtype: String?, width: Int?, height: Int?): ByteArray? {
        return when (mediumType) {
            imageType -> {
                getImageAlbumThumbnail(albumId, mediumSubtype, width, height)
            }
            videoType -> {
                getVideoAlbumThumbnail(albumId, mediumSubtype, width, height)
            }
            else -> {
                getImageAlbumThumbnail(albumId, mediumSubtype, width, height)
                    ?: getVideoAlbumThumbnail(albumId, mediumSubtype, width, height)
            }
        }
    }

    private fun getImageAlbumThumbnail(albumId: String, mediumSubtype: String?, width: Int?, height: Int?): ByteArray? {
        val queryCondition = generateQueryCondition(albumId, MediaStore.Images.Media.BUCKET_ID, mediumSubtype, MediaStore.Images.Media.MIME_TYPE)
        val selectionConditions = queryCondition[0]
        val selection = if (selectionConditions.count() > 0) selectionConditions.joinToString(separator = " AND ") else null
        val selectionArgs = queryCondition[1].toTypedArray()
        return this.context?.run {
            val imageCursor = this.contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                arrayOf(MediaStore.Images.Media._ID),
                selection,
                selectionArgs,
                MediaStore.Images.Media.DATE_TAKEN + " DESC LIMIT 1"
            )
            imageCursor?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val idColumn = cursor.getColumnIndex(MediaStore.Images.Media._ID)
                    val id = cursor.getLong(idColumn)
                    return@run getImageThumbnail(id.toString(), width, height)
                }
            }

            return null
        }
    }

    private fun getVideoAlbumThumbnail(albumId: String, mediumSubtype: String?, width: Int?, height: Int?): ByteArray? {
        val queryCondition = generateQueryCondition(albumId, MediaStore.Video.Media.BUCKET_ID, mediumSubtype, MediaStore.Video.Media.MIME_TYPE)
        val selectionConditions = queryCondition[0]
        val selection = if (selectionConditions.count() > 0) selectionConditions.joinToString(separator = " AND ") else null
        val selectionArgs = queryCondition[1].toTypedArray()
        return this.context?.run {
            val videoCursor = this.contentResolver.query(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                arrayOf(MediaStore.Video.Media._ID),
                selection,
                selectionArgs,
                MediaStore.Video.Media.DATE_TAKEN + " DESC LIMIT 1"
            )
            videoCursor?.use { cursor ->
                if (cursor.moveToNext()) {
                    val idColumn = cursor.getColumnIndex(MediaStore.Video.Media._ID)
                    val id = cursor.getLong(idColumn)
                    return@run getVideoThumbnail(id.toString(), width, height)
                }
            }

            return null
        }
    }

    private fun getFile(mediumId: String, mediumType: String?): String? {
        return when (mediumType) {
            imageType -> {
                getImageFile(mediumId)
            }
            videoType -> {
                getVideoFile(mediumId)
            }
            else -> {
                getImageFile(mediumId) ?: getVideoFile(mediumId)
            }
        }
    }

    private fun getImageFile(mediumId: String): String? {
        var path: String? = null

        this.context?.run {
            val imageCursor = this.contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                arrayOf(MediaStore.Images.Media.DATA),
                "${MediaStore.Images.Media._ID} = $mediumId",
                null,
                null
            )

            imageCursor?.use { cursor ->
                if (cursor.moveToNext()) {
                    val dataColumn = cursor.getColumnIndex(MediaStore.Images.Media.DATA)
                    path = cursor.getString(dataColumn)
                }
            }
        }

        return path
    }

    private fun getVideoFile(mediumId: String): String? {
        var path: String? = null

        this.context?.run {
            val videoCursor = this.contentResolver.query(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                arrayOf(MediaStore.Images.Media.DATA),
                "${MediaStore.Images.Media._ID} = $mediumId",
                null,
                null)

            videoCursor?.use { cursor ->
                if (cursor.moveToNext()) {
                    val dataColumn = cursor.getColumnIndex(MediaStore.Video.Media.DATA)
                    path = cursor.getString(dataColumn)
                }
            }
        }

        return path
    }

    private fun getImageMetadata(cursor: Cursor): Map<String, Any?> {
        val idColumn = cursor.getColumnIndex(MediaStore.Images.Media._ID)
        val widthColumn = cursor.getColumnIndex(MediaStore.Images.Media.WIDTH)
        val heightColumn = cursor.getColumnIndex(MediaStore.Images.Media.HEIGHT)
        val dateTakenColumn = cursor.getColumnIndex(MediaStore.Images.Media.DATE_TAKEN)
        val dateModifiedColumn = cursor.getColumnIndex(MediaStore.Images.Media.DATE_MODIFIED)

        val id = cursor.getLong(idColumn)
        val width = cursor.getLong(widthColumn)
        val height = cursor.getLong(heightColumn)
        var dateTaken: Long? = null
        if (cursor.getType(dateTakenColumn) == FIELD_TYPE_INTEGER) {
            dateTaken = cursor.getLong(dateTakenColumn)
        }
        var dateModified: Long? = null
        if (cursor.getType(dateModifiedColumn) == FIELD_TYPE_INTEGER) {
            dateModified = cursor.getLong(dateModifiedColumn) * 1000
        }

        return mapOf(
            "id" to id.toString(),
            "mediumType" to imageType,
            "width" to width,
            "height" to height,
            "creationDate" to dateTaken,
            "modifiedDate" to dateModified
        )
    }

    private fun getVideoMetadata(cursor: Cursor): Map<String, Any?> {
        val idColumn = cursor.getColumnIndex(MediaStore.Video.Media._ID)
        val widthColumn = cursor.getColumnIndex(MediaStore.Video.Media.WIDTH)
        val heightColumn = cursor.getColumnIndex(MediaStore.Video.Media.HEIGHT)
        val durationColumn = cursor.getColumnIndex(MediaStore.Video.Media.DURATION)
        val dateTakenColumn = cursor.getColumnIndex(MediaStore.Video.Media.DATE_TAKEN)
        val dateModifiedColumn = cursor.getColumnIndex(MediaStore.Video.Media.DATE_MODIFIED)

        val id = cursor.getLong(idColumn)
        val width = cursor.getLong(widthColumn)
        val height = cursor.getLong(heightColumn)
        val duration = cursor.getLong(durationColumn)
        var dateTaken: Long? = null
        if (cursor.getType(dateTakenColumn) == FIELD_TYPE_INTEGER) {
            dateTaken = cursor.getLong(dateTakenColumn)
        }
        var dateModified: Long? = null
        if (cursor.getType(dateModifiedColumn) == FIELD_TYPE_INTEGER) {
            dateModified = cursor.getLong(dateModifiedColumn) * 1000
        }

        return mapOf(
            "id" to id.toString(),
            "mediumType" to videoType,
            "width" to width,
            "height" to height,
            "duration" to duration,
            "creationDate" to dateTaken,
            "modifiedDate" to dateModified
        )
    }
}

class BackgroundAsyncTask<T>(val handler: () -> T, val post: (result: T) -> Unit) : AsyncTask<Void, Void, T>() {
    init {
        execute()
    }

    override fun doInBackground(vararg params: Void?): T {
        return handler()
    }

    override fun onPostExecute(result: T) {
        super.onPostExecute(result)
        post(result)
        return
    }
}
