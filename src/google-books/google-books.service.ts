import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { BooksService } from '../books/books.service';
import { CreateBookDto } from '../books/dto/create-book.dto';

@Injectable()
export class GoogleBooksService {
  private readonly apiKey?: string;
  private readonly baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  constructor(
    private httpService: HttpService,
    private configService: ConfigService,
    private booksService: BooksService,
  ) {
    const apiKey = this.configService.get<string>('GOOGLE_BOOKS_API_KEY');
    this.apiKey = apiKey;
  }

  private ensureApiKey(): void {
    if (!this.apiKey) {
      throw new HttpException(
        'Google Books API key not configured. Set GOOGLE_BOOKS_API_KEY in environment.',
        HttpStatus.SERVICE_UNAVAILABLE,
      );
    }
  }

  async search(query: string) {
    if (!query || query.trim().length === 0) {
      throw new HttpException(
        'Query parameter q is required',
        HttpStatus.BAD_REQUEST,
      );
    }
    try {
      this.ensureApiKey();
      const response = await firstValueFrom(
        this.httpService.get(this.baseUrl, {
          params: {
            q: query,
            key: this.apiKey,
            maxResults: 20,
          },
        }),
      );

      // eslint-disable-next-line @typescript-eslint/no-unsafe-return
      return response.data;
    } catch (error) {
      // If the service already threw a proper HttpException (e.g. 503 when API key missing), rethrow it
      if (error instanceof HttpException) {
        throw error;
      }

      throw new HttpException(
        'Error fetching books from Google Books API',
        // eslint-disable-next-line @typescript-eslint/no-unsafe-argument, @typescript-eslint/no-unsafe-member-access
        error.response?.status || HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  async searchByIsbn(isbn: string) {
    if (!isbn || isbn.trim().length === 0) {
      throw new HttpException('ISBN is required', HttpStatus.BAD_REQUEST);
    }
    try {
      this.ensureApiKey();
      const response = await firstValueFrom(
        this.httpService.get(this.baseUrl, {
          params: {
            q: `isbn:${isbn}`,
            key: this.apiKey,
          },
        }),
      );

      // eslint-disable-next-line @typescript-eslint/no-unsafe-return
      return response.data;
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }

      throw new HttpException(
        'Error fetching book from Google Books API',
        // eslint-disable-next-line @typescript-eslint/no-unsafe-argument, @typescript-eslint/no-unsafe-member-access
        error.response?.status || HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  async enrichBookData(isbn: string) {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
    const googleData = await this.searchByIsbn(isbn);

    // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
    if (!googleData?.items || googleData.items.length === 0) {
      throw new HttpException(
        'Book not found in Google Books',
        HttpStatus.NOT_FOUND,
      );
    }

    // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access
    const bookInfo = googleData.items[0].volumeInfo || {};

    const createBookDto: CreateBookDto = {
      isbn,
      // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access
      title: bookInfo.title || 'Unknown',
      // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-assignment
      author: Array.isArray(bookInfo.authors)
        ? // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-call
          bookInfo.authors.join(', ')
        : // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
          bookInfo.authors || 'Unknown',
      // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access
      publisher: bookInfo.publisher,
      // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access
      publishedDate: bookInfo.publishedDate,
      // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access
      description: bookInfo.description,
      // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access
      pageCount: bookInfo.pageCount,
      // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access
      categories: bookInfo.categories,
      // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access
      language: bookInfo.language,
      // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access
      thumbnail: bookInfo.imageLinks?.thumbnail,
    };

    const existingBook = await this.booksService.findByIsbn(isbn);

    if (existingBook) {
      return this.booksService.update(existingBook.id, createBookDto);
    }

    return this.booksService.create(createBookDto);
  }

  async getVolumeById(volumeId: string) {
    if (!volumeId || volumeId.trim().length === 0) {
      throw new HttpException('Volume id is required', HttpStatus.BAD_REQUEST);
    }

    this.ensureApiKey();

    try {
      const response = await firstValueFrom(
        this.httpService.get(
          `${this.baseUrl}/${encodeURIComponent(volumeId)}`,
          {
            params: {
              key: this.apiKey,
            },
          },
        ),
      );

      // eslint-disable-next-line @typescript-eslint/no-unsafe-return
      return response.data;
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }

      throw new HttpException(
        'Error fetching volume from Google Books API',
        // eslint-disable-next-line @typescript-eslint/no-unsafe-argument, @typescript-eslint/no-unsafe-member-access
        error.response?.status || HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }
}
