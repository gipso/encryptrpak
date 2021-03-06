#' Encrypt/decrypt files from the `extdata` folder
#'
#' @description
#'
#' `r lifecycle::badge("maturing")`
#'
#' `encrypt_extdata()` and `decrypt_extdata()` encrypt/decrypt files from
#' the `extdata` folder of an R package.
#'
#' @details
#'
#' When decrypting, a dialog window will open asking for the key password for
#' each file that must be decrypted. You can only run `decrypt_extdata()` in
#' [interactive][interactive()] mode.
#'
#' The keys must be in a folder named `ssh` that must be present in the system
#' folder (`inst`). The private and public keys must be named `id_rsa` and
#' `id_rsa.pub`, respectively.
#'
#' @param type (optional) a string indicating the folder of the `file` argument.
#'   If `NULL` the function will encrypt/decrypt all files in the `extdata`
#'   folder (default: `NULL`).
#' @param file (optional) a string indicating the file to encrypt/decrypt. If
#'   `file` is `NULL` and `type` is assigned, the function will encrypt/decrypt
#'   all files in the `type` folder (default: `NULL`).
#' @param remove_file (optional) a [`logical`][logical()] value indicating if
#'   the original file must be removed after the encryption/decryption (default:
#'   `TRUE`).
#'
#' @return An invisible `NULL`. The functions are called just for side effects.
#'
#' @template param_a
#' @family encrypt/decrypt functions
#' @export
#'
#' @examples
#' \dontrun{
#' encrypt_extdata()
#' decrypt_extdata()
#' }
encrypt_extdata <- function(type = NULL, file = NULL, remove_file = TRUE,
                            package = gutils:::get_package_name(),
                            devtools_load = FALSE) {
    checkmate::assert_string(package)
    checkmate::assert_character(file, min.len = 1, null.ok = TRUE)
    checkmate::assert_flag(remove_file)
    checkmate::assert_flag(devtools_load)

    devtools_load(devtools_load)
    assert_public_key(package)

    root <- gutils:::find_path("extdata", package = package)
    checkmate::assert_choice(type, list.files_(root), null.ok = TRUE)

    if (is.null(type) && is.null(file)) {
        for (i in list.files_(root, recursive = TRUE)) {
            if (!grepl("\\.encryptr\\.bin$", i)) {
                encrypt_file(file.path(root, i),
                             public_key_path = get_public_key_path(package))

                if (isTRUE(remove_file)) file.remove_(file.path(root, i))
            }
        }
    } else if (!is.null(type) && is.null(file)) {
        for (i in list.files_(file.path(root, type))) {
            if (!grepl("\\.encryptr\\.bin$", i)) {
                encrypt_file(file.path(root, type, i),
                             public_key_path = get_public_key_path(package))

                if (isTRUE(remove_file)) file.remove_(file.path(root, type, i))
            }
        }
    } else if (!is.null(type) && !is.null(file)) {
        for (i in file) {
            if (!(i %in% list.files_(file.path(root, type)))) {
                cli::cli_abort(paste0(
                    "{cli::col_red(gutils:::single_quote_(i))} file cannot ",
                    "be found."
                ))
            }
        }

        for (i in file) {
            if (!grepl("\\.encryptr\\.bin$", i)) {
                encrypt_file(file.path(root, type, i),
                             public_key_path = get_public_key_path(package))

                if (isTRUE(remove_file)) file.remove_(file.path(root, type, i))
            }
        }
    } else {
        cli::cli_abort(paste0(
            "When {cli::col_blue('file')} is assigned the ",
            "{cli::col_red('type')} argument cannot be ",
            "{cli::col_silver('NULL')}."
        ))
    }

    invisible(NULL)
}

#' @rdname encrypt_extdata
#' @export
decrypt_extdata <- function(type = NULL, file = NULL, remove_file = TRUE,
                            package = gutils:::get_package_name(),
                            devtools_load = FALSE) {
    checkmate::assert_string(package)
    checkmate::assert_character(file, min.len = 1, null.ok = TRUE)
    checkmate::assert_flag(remove_file)
    checkmate::assert_flag(devtools_load)

    if (!is_interactive()) {
        cli::cli_abort("This function can only be used in interactive mode.")
    }

    devtools_load(devtools_load)
    assert_private_key(package)

    root <- gutils:::find_path("extdata", package = package)
    checkmate::assert_choice(type, list.files_(root), null.ok = TRUE)

    if (is.null(type) && is.null(file)) {
        for (i in list.files_(root, recursive = TRUE)) {
            if (grepl("\\.encryptr\\.bin$", i)) {
                password_warning()

                decrypt_file(file.path(root, i),
                             private_key_path = get_private_key_path(package))

                if (isTRUE(remove_file)) file.remove_(file.path(root, i))
            }
        }
    } else if (!is.null(type) && is.null(file)) {
        for (i in list.files_(file.path(root, type))) {
            if (grepl("\\.encryptr\\.bin$", i)) {
                password_warning()

                decrypt_file(file.path(root, type, i),
                             private_key_path = get_private_key_path(package))

                if (isTRUE(remove_file)) file.remove_(file.path(root, type, i))
            }
        }
    } else if (!is.null(type) && !is.null(file)) {
        for (i in file) {
            if (!(i %in% list.files_(file.path(root, type)))) {
                cli::cli_abort(paste0(
                    "{cli::col_red(gutils:::single_quote_(i))} file cannot be ",
                    "found."
                ))
            }
        }

        for (i in file) {
            if (grepl("\\.encryptr\\.bin$", i)) {
                password_warning()

                decrypt_file(file.path(root, type, i),
                             private_key_path = get_private_key_path(package))

                if (isTRUE(remove_file)) file.remove_(file.path(root, type, i))
            }
        }
    } else {
        cli::cli_abort(paste0(
            "When {cli::col_blue('file')} is assigned the ",
            "{cli::col_red('type')} argument cannot be ",
            "{cli::col_silver('NULL')}."
        ))
    }

    invisible(NULL)
}
